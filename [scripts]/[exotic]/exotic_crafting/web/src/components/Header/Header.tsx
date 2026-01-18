import { useUserStore } from "../../store/useUserStore";
import "./Header.css";

const Header = () => {
    const { profile, mugshot } = useUserStore();

    return (
        <header>
            <span className="heading">
                <p>STÓŁ RZEMIEŚLNICZY</p>
                <p>
                    Wytwarzaj przedmioty z dostępnych receptur. Część z nich jest ukryta i ukazuje się po wykonaniu danej akcji.
                </p>
            </span>
            <div className="profile">
                <div className="informations">
                    <p>
                        {profile.fullname} (Poziom {profile.level})
                    </p>
                    <div className="progressbar">
                        <div className="progressbar__background">
                            <div 
                                className="progressbar__progress"
                                style={{ width: profile.levelProgress }}
                            />
                        </div>
                        <p className="progressbar__xp">
                            {profile.xp} XP
                        </p>
                    </div>
                </div>
                {mugshot && mugshot !== "none" ? (
                    <img 
                        src={`https://nui-img/${mugshot}/${mugshot}`} 
                        alt="Avatar" 
                        className="header__avatar"
                    />
                ) : (
                    <div className="header__avatar" style={{
                        width: '64px',
                        height: '64px',
                        backgroundColor: '#333',
                        borderRadius: '50%',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        color: '#fff'
                    }}>
                        ?
                    </div>
                )}
            </div>
        </header>
    );
}

export default Header;