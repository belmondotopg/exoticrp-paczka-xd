import { useState, useEffect, Dispatch, SetStateAction } from 'react';
import { fetchNui } from '../../../utils/fetchNui';
import './form.scss';

const COOLDOWN_TIME = 60; // Cooldown time in seconds

const OrderForm: React.FC<{ setHref: Dispatch<SetStateAction<string>> }> = ({ setHref }) => {
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [cooldown, setCooldown] = useState(false);
    const [timeLeft, setTimeLeft] = useState(0);

    const forbiddenWords = [
        "nigger", "niga", "niger", "murzyn", "czarnuch",
        "lgbt", "pedał", "pedal", "pedofil", "pedo",
        "cwel", "cweloza", "cweł", "gej", "ciota"
    ];

    useEffect(() => {
        const lastSubmitted = localStorage.getItem('lastSubmitted');
        if (lastSubmitted) {
            const timeElapsed = Math.floor((Date.now() - parseInt(lastSubmitted)) / 1000);
            if (timeElapsed < COOLDOWN_TIME) {
                setCooldown(true);
                setTimeLeft(COOLDOWN_TIME - timeElapsed);
            }
        }
    }, []);

    useEffect(() => {
        let timer: number | null = null;
        
        if (cooldown) {
            timer = window.setInterval(() => {
                setTimeLeft((prev) => {
                    if (prev <= 1) {
                        setCooldown(false);
                        if (timer !== null) window.clearInterval(timer);
                        return 0;
                    }
                    return prev - 1;
                });
            }, 1000);
        }
        
        return () => {
            if (timer !== null) window.clearInterval(timer);
        };
    }, [cooldown]);

    const containsForbiddenWords = (text: string) => {
        return forbiddenWords.some(word => text.toLowerCase().includes(word));
    };

    const handleTitleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const value = e.target.value;
        if (value.length <= 50 && !containsForbiddenWords(value)) {
            setTitle(value);
        }
    };

    const handleDescriptionChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
        const value = e.target.value;
        if (value.length <= 200 && !containsForbiddenWords(value)) {
            setDescription(value);
        }
    };

    const handleSubmit = () => {
        if (cooldown) return;
        if (!title.trim() || !description.trim()) {
            // Można dodać wyświetlanie błędu
            return;
        }
        if (containsForbiddenWords(title) || containsForbiddenWords(description)) {
            // Można dodać wyświetlanie błędu
            return;
        }
        fetchNui('submitOrder', { title: title, description: description });
        setTitle('');
        setDescription('');
        const now = Date.now();
        try {
            localStorage.setItem('lastSubmitted', now.toString());
        } catch (err) {
            console.error('localStorage error:', err);
        }
        setCooldown(true);
        setTimeLeft(COOLDOWN_TIME);
    };

    const handleClear = () => {
        setTitle('');
        setDescription('');
    };

    return (
        <>
            <div className='kariee_history'>
                <div className="kariee_header">
                    <span>ZAMÓWIENIA</span>
                    <div className="kariee_header_line"></div>
                    <div className="kariee_header_buttons">
                        <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                    </div>
                </div>
                <div className="kariee_history_content">
                    <div className='order-form'>
                        <h2>Tytuł zamówienia</h2>
                        <input
                            type='text'
                            value={title}
                            onChange={handleTitleChange}
                            placeholder='Bronie krótkie'
                        />
                        <h2>Opis zamówienia</h2>
                        <textarea
                            value={description}
                            onChange={handleDescriptionChange}
                            placeholder='Potrzebujemy 20 pistoletów bojowych'
                        ></textarea>
                        <div className='buttons'>
                            <button onClick={handleSubmit} disabled={cooldown}>Wyślij</button>
                            <button onClick={handleClear}>Wyczyść treść</button>
                        </div>
                        {cooldown && <p>Odczekaj {timeLeft} sekund przed następnym wysłaniem.</p>}
                    </div>
                </div>
            </div>
        </>
    );
};

export default OrderForm;