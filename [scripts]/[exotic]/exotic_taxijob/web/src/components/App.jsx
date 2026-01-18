import React, { useState } from "react";
import "./App.css";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";
import { CircleX, RefreshCcw } from "lucide-react";
import { CircleCheck } from "lucide-react";
import UserElement from "./user";
import { useNuiEvent } from "../hooks/useNuiEvent";
// This will set the NUI to visible if we are
// developing in browser
debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

debugData([
  {
    action: "setData",
    data: [
    {
     name: "Jan Kowalski",
     stars: 4.5,
     distanceToMe: 1200,
     distanceToTarget: 5000,
     vip: false,
     id: 1,

    },
    {
     name: "Anna Nowak",
     stars: 4.8,
     distanceToMe: 800,
     distanceToTarget: 3000,
     vip: true,
     id: 2,

    },
    {
     name: "Piotr Wiśniewski",
     stars: 4.2,
     distanceToMe: 1500,
     distanceToTarget: 7000,
     vip: false,
     id: 3,

    },
    {
     name: "Katarzyna Wójcik",
     stars: 4.9,
     distanceToMe: 600,
     distanceToTarget: 2500,
     vip: true,
     id: 4,

    },
    {
     name: "Michał Kowalczyk",
     stars: 4.3,
     distanceToMe: 1300,
     distanceToTarget: 5500,
     vip: false,
     id: 5,

    },
    {
     name: "Agnieszka Kamińska",
     stars: 4.7,
     distanceToMe: 900,
     distanceToTarget: 3500,
     vip: true,
     id: 6,

    },
    ],
  },
]);




const App = () => {
  const [clientData, setClientData] = useState([]);
  const [autoMode, setAutoMode] = useState(false);
  const [haveRoute, setHaveRoute] = useState(false);
  useNuiEvent('setData', setClientData)
  useNuiEvent('haveRoute', setHaveRoute)
  const handleGetClientData = () => {
    fetchNui("getClientData")
      .then((retData) => {
        console.log("Got return data from client scripts:");
        console.dir(retData);
        setClientData(retData);
      })
      .catch((e) => {
        console.error("Setting mock data due to error", e);
        setClientData({ x: 500, y: 300, z: 200 });
      });
  };


  const Refresh = () => {
    fetchNui("RefreshData")
      .then((retData) => {
        console.log("Got return data from client scripts:");
        console.dir(retData);
      })
      .catch((e) => {
        console.error("Setting mock data due to error", e);
      });
  }

  const ToggleAuto = () => {
    fetchNui("ToggleAuto", {auto: !autoMode})
      .then((retData) => {
        console.log("Got return data from client scripts:");
        console.dir(retData.data);
        setAutoMode(retData.data);
      })
      .catch((e) => {
        console.error("Setting mock data due to error", e);
      });
  }


  return (
    <div className="nui-wrapper">
      <div className="popup-thing">
        <div className="header">
          <button className="top" onClick={ToggleAuto}>
            {!autoMode ? <CircleX /> : <CircleCheck />}
            {!autoMode
              ? "Automatyczne Przejazdy Wyłączone"
              : "Automatyczne Przejazdy Włączone"}
          </button>
          <button className="top" onClick={Refresh}>
            <RefreshCcw />
          </button>
        </div>
        <div className="users-list">
  {[...clientData]
  .sort((a, b) => a.distanceToMe - b.distanceToMe)
  .map((user, index) => (
    <UserElement
      key={user.id || index}
      name={user.name}
      stars={user.stars}
      distanceToMe={user.distanceToMe}
      distanceToTarget={user.distanceToTarget}
      vip={user.vip}
      id={user.id}
      canClick={!haveRoute}
      setCanClick={setHaveRoute}
    />
))}

</div>
      </div>
    </div>
  );
};

export default App;
