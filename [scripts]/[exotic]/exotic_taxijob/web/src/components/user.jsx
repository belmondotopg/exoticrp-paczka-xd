import React, { useState } from "react";
import "./App.css";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";
import { Check, Crown, MapIcon, Star, User } from "lucide-react";



const UserElement = ({
  name,
  stars,
  distanceToMe,
  distanceToTarget,
  vip,
  id,
  canClick,
  setCanClick
}) => {
  const [clientData, setClientData] = useState(null);
  const [autoMode, setAutoMode] = useState(false);
  const handleClick = () => {
    if(!canClick) return;
    setCanClick(false);
    fetchNui("startRoute", { id }).then((retData) => {
      console.log(retData.success)
      if (retData.success) {
        setCanClick(true);
      }
    });

  }

  return (
    <div className="user-wrapper">
      <div className="user-left">
        <div className="user-info">
          {!vip ?<User height='40px' width='40px' /> : <Crown height='40px' width='40px'/>}
          <div className="user-info-right">
            <div className="user-name">{name}</div>
            <div className="user-distance">{(distanceToMe / 1000).toFixed(1)}km od Ciebie</div>
          </div>
          <div className="icon-wrapper">
            <Star /> {stars}
          </div>
          <div className="icon-wrapper">
            <MapIcon /> {(distanceToTarget / 1000).toFixed(1)}km
          </div>
        </div>

      </div>
              <button className="top" onClick={handleClick} style={{
                cursor:   canClick ? "pointer" : "not-allowed"
              }}><Check/> Rozpocznij Przejazd</button>
    </div>
  );
};

export default UserElement;
