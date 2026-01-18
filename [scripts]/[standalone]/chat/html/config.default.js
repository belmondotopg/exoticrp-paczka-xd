window.CONFIG = {
  defaultTemplateId: 'default',
  defaultAltTemplateId: 'defaultAlt',
  templates: {
    default: '<div style="word-break: break-word; padding: 0.52vw; font-size: 0.79rem; transition: all 1s ease;-webkit-font-smoothing: antialiased;-moz-osx-font-smoothing: grayscale; margin: 0vw; border-radius: 3px; background-color: rgba({2}, {3}, {4}, 0.6);"><i class="{5}"></i> <b style="color: rgb({6}, {7}, {8});">{0}:</b><span style="font-weight: 500">{1}</span></div>',
    pixel: '<div style="word-break: break-word; padding: 0.52vw; margin: 0.26vw; background-color: rgba({2}, {3}, {4}, 0.75); border-radius: 0.26vw; font-weight: 600; font-family: "Lato", Helvetica, Arial, sans-serif!important; text-shadow: 0px 0px 0px white!important;"> <span style="font-weight: 900;!important; font-family: "Lato", Helvetica, Arial, sans-serif!important; text-shadow: 0px 0px 0px white!important; font-size: 1rem;">[{0}]:</span> {1}</div>',
    defaultAlt: '{0}',
    print: '<pre style="font-family: Consolas, Menlo, Monaco, Lucida Console, Liberation Mono,DejaVu Sans Mono, Bitstream Vera Sans Mono, Courier New, monospace, serif;">{0}</pre>', 'example:important': '<h1>^2{0}</h1>',
  },
  fadeTimeout: 10000,
  suggestionLimit: 20,
  style: {
    background: 'rgba(155, 155, 155, 0)',
    width: '30%',
    height: '25%',
  },
};