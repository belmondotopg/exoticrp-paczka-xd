window.APP = {
  template: '#app_template',
  name: 'app',
  data() {
    return {
      style: CONFIG.style,
      showInput: false,
      showWindow: false,
      shouldHide: true,
      backingSuggestions: [],
      removedSuggestions: [],
      templates: CONFIG.templates,
      message: '',
      messages: [],
      oldMessages: [],
      oldMessagesIndex: -1,
      tplBackups: [],
      msgTplBackups: [],
      PageUP: false,
    };
  },
  destroyed() {
    clearInterval(this.focusTimer);
    window.removeEventListener('message', this.listener);
  },
  mounted() {
    try {
      post('https://chat/loaded', JSON.stringify({}));
      this.listener = window.addEventListener('message', (event) => {
        try {
          const item = event.data || event.detail;
          if (this[item.type]) {
            this[item.type](item);
          }
        } catch (error) {
          console.error('[CHAT] Błąd przetwarzania wiadomości:', error);
        }
      });
    } catch (error) {
      console.error('[CHAT] Błąd inicjalizacji czatu:', error);
    }
  },
  watch: {
    messages() {
      if (this.showWindowTimer) {
        clearTimeout(this.showWindowTimer);
      }
      this.showWindow = true;
      $('#app').animate({ marginTop: '0px', opacity: 1.0 }, 500);
      this.resetShowWindowTimer();

      const messagesObj = this.$refs.messages;
      this.$nextTick(() => {
        if (!this.PageUP) {
          messagesObj.scrollTop = messagesObj.scrollHeight;
        }
      });
    },
  },
  computed: {
    suggestions() {
      return this.backingSuggestions.filter(
        (el) => this.removedSuggestions.indexOf(el.name) <= -1
      );
    },
  },
  methods: {
    ON_SCREEN_STATE_CHANGE({ shouldHide }) {
      this.shouldHide = shouldHide;
    },
    CHATSCALE({ width }) {
      try {
        const elements = ['chat-window', 'chat-messages', 'chat-input', 'suggestions-wrap'];
        elements.forEach(id => {
          const element = document.getElementById(id);
          if (element) {
            element.style.width = width;
          }
        });
      } catch (error) {
        console.error('[CHAT] Błąd skalowania czatu:', error);
      }
    },
    ON_OPEN() {
      this.showInput = true;
      this.showWindow = true;
      $('#app').animate({ marginTop: '0px', opacity: 1.0 }, 500);
      if (this.showWindowTimer) {
        clearTimeout(this.showWindowTimer);
      }
      this.focusTimer = setInterval(() => {
        if (this.$refs.input) {
          this.$refs.input.focus();
        } else {
          clearInterval(this.focusTimer);
        }
      }, 100);
    },
    ON_CLOSE() {
      if (this.PageUP) {
        this.PageUP = false;
      }
    },
    ON_MESSAGE({ message }) {
      if (message.args[0] !== '') {
        this.messages.push(message);
        if (this.PageUP) {
          this.PageUP = false;
        }
      }
    },
    ON_CLEAR() {
      this.messages = [];
      this.oldMessages = [];
      this.oldMessagesIndex = -1;
      if (this.PageUP) {
        this.PageUP = false;
      }
    },
    ON_SUGGESTION_ADD({ suggestion }) {
      const duplicateSuggestion = this.backingSuggestions.find(
        (a) => a.name === suggestion.name
      );
      if (duplicateSuggestion) {
        if (suggestion.help || suggestion.params) {
          duplicateSuggestion.help = suggestion.help || '';
          duplicateSuggestion.params = suggestion.params || [];
        }
        return;
      }
      if (!suggestion.params) {
        suggestion.params = [];
      }
      this.backingSuggestions.push(suggestion);
    },
    ON_SUGGESTIONS_ADD_BATCH({ suggestions }) {
      if (!suggestions || !suggestions.length) return;
      
      const existingNames = new Set(this.backingSuggestions.map(s => s.name));
      const newSuggestions = [];
      
      for (let i = 0; i < suggestions.length; i++) {
        const suggestion = suggestions[i];
        if (existingNames.has(suggestion.name)) {
          const existing = this.backingSuggestions.find(s => s.name === suggestion.name);
          if (existing && (suggestion.help || suggestion.params)) {
            existing.help = suggestion.help || '';
            existing.params = suggestion.params || [];
          }
        } else {
          if (!suggestion.params) {
            suggestion.params = [];
          }
          newSuggestions.push(suggestion);
          existingNames.add(suggestion.name);
        }
      }
      
      if (newSuggestions.length > 0) {
        this.backingSuggestions = this.backingSuggestions.concat(newSuggestions);
      }
    },
    ON_SUGGESTION_REMOVE({ name }) {
      if (this.removedSuggestions.indexOf(name) <= -1) {
        this.removedSuggestions.push(name);
      }
    },
    ON_TEMPLATE_ADD({ template }) {
      if (this.templates[template.id]) {
        this.warn(`Tried to add duplicate template '${template.id}'`);
      } else {
        this.templates[template.id] = template.html;
      }
    },
    ON_UPDATE_THEMES({ themes }) {
      this.removeThemes();

      this.setThemes(themes);
    },
    removeThemes() {
      for (let i = 0; i < document.styleSheets.length; i++) {
        const styleSheet = document.styleSheets[i];
        const node = styleSheet.ownerNode;

        if (node.getAttribute('data-theme')) {
          node.parentNode.removeChild(node);
        }
      }

      this.tplBackups.reverse();

      for (const [elem, oldData] of this.tplBackups) {
        elem.innerText = oldData;
      }

      this.tplBackups = [];

      this.msgTplBackups.reverse();

      for (const [id, oldData] of this.msgTplBackups) {
        this.templates[id] = oldData;
      }

      this.msgTplBackups = [];
    },
    setThemes(themes) {
      for (const [id, data] of Object.entries(themes)) {
        if (data.style) {
          const style = document.createElement('style');
          style.type = 'text/css';
          style.setAttribute('data-theme', id);
          style.appendChild(document.createTextNode(data.style));

          document.head.appendChild(style);
        }

        if (data.styleSheet) {
          const link = document.createElement('link');
          link.rel = 'stylesheet';
          link.type = 'text/css';
          link.href = data.baseUrl + data.styleSheet;
          link.setAttribute('data-theme', id);

          document.head.appendChild(link);
        }

        if (data.templates) {
          for (const [tplId, tpl] of Object.entries(data.templates)) {
            const elem = document.getElementById(tplId);

            if (elem) {
              this.tplBackups.push([elem, elem.innerText]);
              elem.innerText = tpl;
            }
          }
        }

        if (data.script) {
          const script = document.createElement('script');
          script.type = 'text/javascript';
          script.src = data.baseUrl + data.script;

          document.head.appendChild(script);
        }

        if (data.msgTemplates) {
          for (const [tplId, tpl] of Object.entries(data.msgTemplates)) {
            this.msgTplBackups.push([tplId, this.templates[tplId]]);
            this.templates[tplId] = tpl;
          }
        }
      }
    },
    warn(msg) {
      this.messages.push({
        args: [msg],
        template: '^3<b>CHAT-WARN</b>: ^0{0}',
      });
    },
    clearShowWindowTimer() {
      clearTimeout(this.showWindowTimer);
    },
    resetShowWindowTimer() {
      this.clearShowWindowTimer();
      this.showWindowTimer = setTimeout(() => {
        if (!this.showInput) {
          $('#app').animate({ marginTop: '-300px', opacity: 0.5 }, 500);
          setTimeout(() => {
            this.showWindow = false;
          }, 1000);
        }
      }, CONFIG.fadeTimeout);
    },
    keyDown(e) {
      if (e.which === 38 || e.which === 40) {
        e.preventDefault();
        this.moveOldMessageIndex(e.which === 38);
      } else if (e.which === 33) {
        var buf = document.getElementsByClassName('chat-messages')[0];
        const scrollAmount = window.innerHeight * 0.093;
        buf.scrollTop = buf.scrollTop - scrollAmount;
        this.PageUP = true;
        const messagesObj = this.$refs.messages;
        if (messagesObj.scrollTop === messagesObj.scrollHeight)
          this.PageUP = false;
      } else if (e.which === 34) {
        var buf = document.getElementsByClassName('chat-messages')[0];
        const scrollAmount = window.innerHeight * 0.093;
        buf.scrollTop = buf.scrollTop + scrollAmount;
        this.PageUP = true;
      } else if (e.which === 9) {
        e.preventDefault();
        this.autocomplete();
      } else if (e.which === 27) {
        this.PageUP = false;
      }
    },
    moveOldMessageIndex(up) {
      if (up && this.oldMessages.length > this.oldMessagesIndex + 1) {
        this.oldMessagesIndex += 1;
        this.message = this.oldMessages[this.oldMessagesIndex];
      } else if (!up && this.oldMessagesIndex - 1 >= 0) {
        this.oldMessagesIndex -= 1;
        this.message = this.oldMessages[this.oldMessagesIndex];
      } else if (!up && this.oldMessagesIndex - 1 === -1) {
        this.oldMessagesIndex = -1;
        this.message = '';
      }
      this.$nextTick(() => {
        this.resize();
      });
    },
    resize() {
      const input = this.$refs.input;
      if (!input) return;
      const minHeight = window.innerHeight * 0.037; // 3.7vh w pikselach
      if (this.message === '') {
        input.style.height = '3.7vh';
        return;
      }
      input.style.height = '3.7vh';
      if (input.scrollHeight > minHeight) {
        input.style.height = `${input.scrollHeight}px`;
      }
    },
    send(e) {
      try {
        if (this.message !== '') {
          post(
            'https://chat/chatResult',
            JSON.stringify({
              message: this.message,
            })
          );
          this.oldMessages.unshift(this.message);
          this.oldMessagesIndex = -1;
          this.hideInput();
        } else {
          this.hideInput(true);
        }
      } catch (error) {
        console.error('[CHAT] Błąd wysyłania wiadomości:', error);
        this.hideInput(true);
      }
    },
    hideInput(canceled = false, clearMessage = true) {
      if (canceled) {
        post('https://chat/chatResult', JSON.stringify({ canceled }));
      }
      this.message = '';
      this.showInput = false;
      clearInterval(this.focusTimer);
      if (this.$refs.input) {
        this.$refs.input.style.height = '';
      }
      this.resetShowWindowTimer();
    },
  },
};
