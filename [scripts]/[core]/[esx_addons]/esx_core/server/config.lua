Config = {}

Config.Logs = {
    Channels = {
        -- Restart
        ['restart']             = 'https://discord.com/api/webhooks/1439652885498695682/W8R3zTqsVqg0div6aRdWN9kHbIyyGH3RW0ddVcPtQ-BG5fR4YTGQ0SJ7Dy7EVaSKM0KT',
        -- Prace
        ['lumberjack']          = "https://discord.com/api/webhooks/1457898485805224067/sc0Y9Salo-NeDzdA9z7j6DM_A-2_DNo9TUFD8oMwBdtblO6fgwSfw_cCHO_Q8eaHQtJZ",
        ['weazelnews']          = "https://discord.com/api/webhooks/1457898314056995102/tVMuSZltt4ZUKoU1-gj3xE5DIHKS01yX4XHSA0ssQYxR03wCy77ZMFaTKimp9LCkpvmy",
        ['orangeharvest']       = "https://discord.com/api/webhooks/1457898556466794696/psqlOuhTXvfHN4wE_4KwryMSOTbWwrMuYubXkxgNASyJzNJy1Lr3CKb3OSoJnEsPX0oN",
        ['taxi']                = "https://discord.com/api/webhooks/1457911004192178227/I2QRtTjREwrSkM2ePZpy4zC3CAIKWGVqHs9Cl4zbmO1xBbfLfnwW7ogBdpsyKzHRuB71",

        -- Pozostałe
        ['connect']             = "https://discord.com/api/webhooks/1438853847320629259/947HdUsLhRJfd3BKPqNJyLNZcbmTX370iSgKMTXg3vC30QTf49HbJPNcF7OA7IN0OtMf",
        ['disconnect']          = "https://discord.com/api/webhooks/1457885463107866695/je2e8VWqVEZSbBLaL_Ti3mrO8C821euVaByPDpQJBf4ZDwy6XjQwRfufr32sEXDepg7R",
        ['queue']               = "https://discord.com/api/webhooks/1438854017454309416/C1jkEXjUjIySCXCjonFgQhqbwaOecjYdJLRuRFs-Mpb6XNLpfTMnRXNgSKfPb2AKctgA",
        ['bans-commands']       = "https://discord.com/api/webhooks/1438860789078556815/hwxeGclZ4eef9Pyx3pzSpRwgsp3SIEMqf4GTizrv-STLhdBRi4BYM8Sp7ByvWw0XmsQa",
        ['clearmap']            = "https://discord.com/api/webhooks/1438860989675208799/TQB02W1TY5INXDUflsmBpZqMt1XXmZpfErO2GKw8U2ljfb6o1PUyEwGBPaOASFhi6QJP",
        ['ac']                  = "https://discord.com/api/webhooks/1438861287105761292/0nIH_-aZ7-siUInbogSvHAE0wnlUnruBrbk5V1RH4eiJ4YlqO-UVX1Fs4o44ModbQ0Ie",
        ['car-sell']            = "https://discord.com/api/webhooks/1438861473148436582/RyuJDQiwM8hjakUJpei_1FIio990J5lvOujTLGxa0P86aELE0tGi6_wKasgqOGvaBb-Y",
        ['lombard']             = "https://discord.com/api/webhooks/1438861814405402695/BtuORVT512MfbtUAxxpjzOoWkvWOjRArhrqp2R2MitjyA_8XYD2ZbyzvTUbvEGb9LDpx",
        ['giveitem']            = "https://discord.com/api/webhooks/1438861877689057281/2qm1RvwR155qj6Y2dSQ3LYYHPZRfeqjhE7bAQ1dR54n_E5PNu5T1Fk_0wmZd1NG3zaR2",
        ['removeitem']          = "https://discord.com/api/webhooks/1438861939831869461/_9wyNzb6HMI-7azbuicxcHWElaoib5HUcSTuxzSJijdnhfL2O8jmZfP-IxnWTe_lgLYW",
        ['clearinv']            = "https://discord.com/api/webhooks/1438861989366464692/F9M4Jb9tQGojKDhfiT6QSl1E1JPyn-DRGjTdi6vZhJeSt40SXowWt1eS79bO-EznPVHB",
        ['viewinv']             = "https://discord.com/api/webhooks/1438862150863949915/lKQzmvBJOyI_no9VPSOsHfUXtK2WbffwEx1Z-C5cEr-YIL8_5uHdIufnbIly3vgOFN7_",
        ['inventory-szafki-org']= "https://discord.com/api/webhooks/1438871787520655380/akHjpeuIGBn5Kc6Bb0Ygwt3NSqImQOhxAgtLGqrHlMnEKME1Zs584pWz0pNdkObvwjkK",
        ['inventory-szafki-fraction'] = "https://discord.com/api/webhooks/1438873417301626992/GK_PwxqwYRx11FgtJlWWbCTibNDT7ClkDNrCZMZpdg2_fllcrqndXrDeR6bZcUMEUawm",
        ['drop']                = "https://discord.com/api/webhooks/1438875264519114872/zIPqivaA5gkBvLl9ULD8kL4CleTkdk58kijvS58Lr5Yq7wrp-XnTDkV9CT2PVJ92hdry",
        ['suspicious']          = "https://discord.com/api/webhooks/1438902485010874381/UizjELY6mjZn-vYZ04Lw9MF1orSzflKmyEVXp86zj5cE9gcUmOH3DAGlVRzx9dD8p5BJ",
        ['swap']                = "https://discord.com/api/webhooks/1438902550870097971/xdB7J5owY78vMmn9PbZgRzJSebtaHwkWOeDyP2Zo1kCyq5GbI_MLD9R3I5TtHQIWnTAK",
        ['apartamenty-szafka']  = "https://discord.com/api/webhooks/1438905637047238687/F1TjsOgjtBawshupsaTg79HlR1fYPwOgTrFFoRRqE7_DcHKbHh9VZ4fjTrGEZyKIuPLO",
        ['additem']             = "https://discord.com/api/webhooks/1438906916821799015/dunAc2GKth7b2xlOMtHSsqAyyl558ecsHqZp_KjB8kydzSt7ZSCESO_-ElsxKjclKiYH",
        ['bagaznik-szafka']     = "https://discord.com/api/webhooks/1438906968570859600/2GIbILjr4E3UXj9bRlJP-dseu6XFSwXbvEYVQU8d6XYtDHiC8AeXkd0XMj4S1JzTe4Z-",
        ['other']               = "https://discord.com/api/webhooks/1438906968570859600/2GIbILjr4E3UXj9bRlJP-dseu6XFSwXbvEYVQU8d6XYtDHiC8AeXkd0XMj4S1JzTe4Z-",
        ['crafting-repair']     = "https://discord.com/api/webhooks/1438906968570859600/2GIbILjr4E3UXj9bRlJP-dseu6XFSwXbvEYVQU8d6XYtDHiC8AeXkd0XMj4S1JzTe4Z-",
        ['heist-general']       = "https://discord.com/api/webhooks/1438907084618862738/C1RzqeuafNYLuzHJcq5WeVZ7wSgQak-2JD4SX1r7bE7PY7zr6r90n_eTDzBk65Go7Ec7",
        ['zdrapki']             = "https://discord.com/api/webhooks/1438907356510420993/HjfaKJf1SZRifWPib4IRvZNHnomT1oQBNYqvtp_a27KqcwIVAsPJDqCCXv27TtkHYusJ",
        ['bossmenu']            = "https://discord.com/api/webhooks/1438908671408214089/ZRUndxAlKER93-8EcerfGLuzNGoQApUuJVomiF7eghP76ZKJA6LdkTMsCVApewtvC2b0",
        ['chat']                = "https://discord.com/api/webhooks/1438909031463911556/SAHa6e2AN_IyVgtkqtQca01gGQNzH_RTK3dxlsxCInXJWz2Ff0-5Ynm1G3zt05hO699s",
        ['opis-first']          = "https://discord.com/api/webhooks/1438909231561445386/O6yWDsWEGvsKEK5xM1dH7XfQbdzj64goHt0qhrDZeRrt2hLMiNnDxq6EV4DDznksweLA",
        ['opis-second']         = "https://discord.com/api/webhooks/1438909659946946621/fPe9J_cC2fVX-6XNz5tYxaAmCV1gjncrue0ug65FyI818AIeNoU-W4qbjC7meXj9_96n",
        ['ActivatePhysics']     = "https://discord.com/api/webhooks/1438861287105761292/0nIH_-aZ7-siUInbogSvHAE0wnlUnruBrbk5V1RH4eiJ4YlqO-UVX1Fs4o44ModbQ0Ie",
        ['kills']               = "https://discord.com/api/webhooks/1438910053397565471/ql6z3XsUnBYksnSitwzP1y15bV4_E3GiXDvm6bhrkjdpvut08t3AsU-FcdfLSNHp7XR4",
        ['teleports']           = "",
        ['ems-hospital']        = "https://discord.com/api/webhooks/1438913385751248907/XdBBQ2uRFmlKD1tCtAaQcd_RicM8bWrzyRigwqlN8F6WOqElO2w6jUlZKtr2NXOXKQED",
        ['revive']              = "https://discord.com/api/webhooks/1438913529351635126/TfmcZ1ufx3zrTh18GY4SI--Y7EDhmDZCpto6rdimvhVaO7M9riKe8X-2GZSY46xIzsAR",
        ['cl']                  = "https://discord.com/api/webhooks/1438913835087036436/esHnk2wosePoh1fY1wg0ngJT2aThEWreaoimy161pA-Yybf12dysWDhM5RAQZkIlxyDh",
        ['ems-revive']          = "https://discord.com/api/webhooks/1438914207000166400/3S28LWHNGUXV7ilqtWeCEbHAkYbUWSgb3CvExYBZa2Xw-B2SbQDAiBJjnhp4pQG4sAAE",
        ['admin-heal']          = "https://discord.com/api/webhooks/1438914283605065884/NAS0jEwhD_ZAynDcDqrw7ViQ4H33F1J-_El_EiiEzafs8ClqJ_wGTbQGLe-fgNkw4FxE",
        ['drugs-collecting']    = "https://discord.com/api/webhooks/1438914379545313303/2Xtazlq8pCOx70UhYftOPrmkgVjkF1xG3MAaO4q8zbDVhBndkyKDMpkeHxD0hoGULAv1",
        ['drugs-packing']       = "https://discord.com/api/webhooks/1438914379545313303/2Xtazlq8pCOx70UhYftOPrmkgVjkF1xG3MAaO4q8zbDVhBndkyKDMpkeHxD0hoGULAv1",
        ['selldrugs']           = "https://discord.com/api/webhooks/1438914530800435210/bJQZk8tP0Dpw4DPXNvYcIyLwZt-Lu4gnmPt7ADgVq0vh_1CiN5YRaAU10k5YoVCGds2e",
        ['hancuffs-cuff']       = "https://discord.com/api/webhooks/1438915240824799282/zDh5trD17_7wR3gio7RMuIUpzb4saLP6rMkwRuF3AEEPsuxZccz_YM_Pf8mefNauc7l5",
        ['hancuffs-search']     = "https://discord.com/api/webhooks/1438915192229593229/g2ypVOxv6GadNH6QYDxtnRofq9Xl6PQIzTn_xz_VM35sUTlG3pbm4p7F9O7Syo08zPvW",
        ['hancuffs-drag']     = "https://discord.com/api/webhooks/1438915877813616762/6QUUU1jRdKIOCznGP4oD67OcjRKu8ShGRid2gA2RD7ZJCZmRDQIfpwSywAAhaVooNkLb",
        ['license-set']         = "https://discord.com/api/webhooks/1438916203619024926/z7EIfQ7-Sla36M1CCWylcaVAH_FVxwXZ7orli532eC-pV_hSwPovRb6R2xZJay-62LEl",
        ['license-take']        = "https://discord.com/api/webhooks/1438916203619024926/z7EIfQ7-Sla36M1CCWylcaVAH_FVxwXZ7orli532eC-pV_hSwPovRb6R2xZJay-62LEl",
        ['license-check']       = "https://discord.com/api/webhooks/1438916203619024926/z7EIfQ7-Sla36M1CCWylcaVAH_FVxwXZ7orli532eC-pV_hSwPovRb6R2xZJay-62LEl",
        ['wiezienie-jail']           = "https://discord.com/api/webhooks/1438916343553331201/iLJ9XzY8hDKpTYgftMpeq6TM0-SmZ86BTicUz0O84yIfpeXYXVQ_Rx4kJTzef4wWq2QV",
        ['wiezienie-unjail']    = "https://discord.com/api/webhooks/1457852765697999006/D5W34IlWWMnSRPb_7wcN4XFPbGyFAyXBs0P-fL7nMSEw-w9eAy0QLbxdOreRhPInnX2J",
        ['heist-npc']           = "https://discord.com/api/webhooks/1438916649850896415/haKvoqMfa0V2BvnqLSYFRu2xE6mX11nX9-pw5Stn5Fx1I2-ajjC453d_FpaNMMRjr4rq",
        ['sklep']               = "https://discord.com/api/webhooks/1438917685902577825/QBrnKiXDBP9HHALg-4Q3HwY53IgA0v7ZleuJWArx_eMgXmXJYoA4saEenL2bietoLUK3",
        ['parkingpd-odholowywanie'] = "https://discord.com/api/webhooks/1438917865506865172/9xyY4XJzNrlY2y2F5QW7UcD--N6UbvmgvDjf2GrVNc_2IIAsDx1uDKT4F0yjGWZ-auUP",
        ['parkingpd-zajmowanie']   = "https://discord.com/api/webhooks/1438917865506865172/9xyY4XJzNrlY2y2F5QW7UcD--N6UbvmgvDjf2GrVNc_2IIAsDx1uDKT4F0yjGWZ-auUP",
        ['fraction-fines']      = "https://discord.com/api/webhooks/1444796937995030589/DZeHBjhSR-NH-widGm-jjM3wqJ6A284kynXDFqlVbOxdCFTP-7vEpmTVz8Pji4dZ1BzL",
        ['fraction-invoices']   = "https://discord.com/api/webhooks/1457893645507366953/gFjrnfd9z6bv91jqjcISpsjdDhweRjTk2FUjOvdTzEjGOPcpGQNKLaLNwhpz6AYZz4et",
        ['vehicleshop']         = "https://discord.com/api/webhooks/1455654171712815206/WYXl2pQJ1mUlwlAYA0-r7IaFDgp1reUO2MzCDSJn8g9SIl0r5xa-OfX3kdForBqc2IQh",
        ['dangerCode']          = "https://discord.com/api/webhooks/1457852534105575538/ZMajo10ghTy9RmfoZfEFQdRIVer5FGMda0QjptBGguTZd7B245Mjp-L1tABAbF2dW8FY",
        ['skinmenu']            = "https://discord.com/api/webhooks/1457852597104017448/I_5u8uBR1DLtUI2aeUpdjItixtDf1KO7uMwA4ketsT0xSsfOgHbmaJ9CoypGWVmmKPW5",
        ['contract-item']       = "https://discord.com/api/webhooks/1457901711166406716/fPd5tawE7MbAq8yoipbSqHq3tm36hzWlLnky1Y94MBUBl_pIGO1rd66JczCsIUT2mSV1",
        ['contract-vehicle']    = "https://discord.com/api/webhooks/1438861473148436582/RyuJDQiwM8hjakUJpei_1FIio990J5lvOujTLGxa0P86aELE0tGi6_wKasgqOGvaBb-Y",
        ['houses']              = "https://discord.com/api/webhooks/1438905637047238687/F1TjsOgjtBawshupsaTg79HlR1fYPwOgTrFFoRRqE7_DcHKbHh9VZ4fjTrGEZyKIuPLO",
        ['rybak-lowienie']      = "https://discord.com/api/webhooks/1457898218909077598/3buvWzLOdN658h4ytaXUTKfyySMyxKnYteHWuqFc1dgoXz-8wRCTtBOBTu-oSqfJKtGi",
        ['rybak-sprzedaz']      = "https://discord.com/api/webhooks/1457898218909077598/3buvWzLOdN658h4ytaXUTKfyySMyxKnYteHWuqFc1dgoXz-8wRCTtBOBTu-oSqfJKtGi", 

        -- Admin Commands
        ['admin-commands']      = "https://discord.com/api/webhooks/1438918284782207090/XPOeb_ETV2PKSfjcAYO43dPdvGOFroo8E026gkEmO0QaHMQlkFBhwfsZY_GolxaW5IGk",
        ['admin-kick']          = "https://discord.com/api/webhooks/1438918345989689475/ypCAmFxcj10KXEaXXKtDHryKoogP42DoMx8q-lx_O4m3DMAsfKCd6BCpqApXe6CdT2xy",
        ['admin-coords']        = "https://discord.com/api/webhooks/1438918410271457471/Py0VuUXHA9syvLtr_1X3V_QNwVlsU6nOAQq_Ap5ehaU6fNPUjRRzV8stiWI8JdyOxmSZ",
        ['admin-car']           = "https://discord.com/api/webhooks/1438918468383674380/SjkJFKSPs3Z6p-oS_pvJVPJm_uV1MDbv_llPA0f741AKyNVc4CE7huLwsdlShHw7qwd4",
        ['admin-cardel']        = "https://discord.com/api/webhooks/1438918546217242654/3HqU6x4mcdx-jQoRZG_wzc9_25VfzcqgBOlhxpejandSNjslEAWpzxVQVzEYq3u42_Tf",
        ['admin-money']         = "https://discord.com/api/webhooks/1394704612270936255/AFvcyPigF-kE0svLhC1lvl1vti0wLPnLJPQLtaJYyDjhPhvebCle6v6sF9oSza0VBrwM",
        ['admin-group']         = "https://discord.com/api/webhooks/1438918742766518292/QxB4IOdbaXQ1kSzSX1YD6vEXjTw077oBcAgJ2ZoIye2G5CUwh4KMG-p_-ZIe-EpVEkKw",
        ['admin-revivedist']    = "https://discord.com/api/webhooks/1438918931967512586/fL8U_tycR7QxPMcW-5CFSp25IVdHjQvXd_SF_y6fWDBYug8mDsCXScbHh2i2DR71BYGm",
        ['admin-spawn']         = "https://discord.com/api/webhooks/1438919192148705384/qUwKdt2lMS-kbyuTALyQ6HCB-yS2mzAT5wSLkiTXTSyAgoqGfOBYBJSPaPcLWMzwZy1U",
        ['admin-fix']           = "https://discord.com/api/webhooks/1438919447091089471/iZGrwZrrYQbpbEkxjO6sXznTMo7PdvaoUb2lGKaf5nweeaaO76ggPTRcOKxW_YW4z71C",
        ['admin-slay']          = "https://discord.com/api/webhooks/1438919610714947758/PKbAyA2LkQkZJSPbfUIqnSslsk8royrmSKqWQfBiJ3Z38634Z6WhTVNwgSyHWDhtMnCN",
        ['admin-updateplate']   = "https://discord.com/api/webhooks/1438919740595634207/Hq1NrI-02uacAyua1aiLZFPjAKzXw37xRmcdQHPWsn4t9hwoSgttCdqNxgKbL3w051Rb",
        ['admin-delcar']        = "https://discord.com/api/webhooks/1438918546217242654/3HqU6x4mcdx-jQoRZG_wzc9_25VfzcqgBOlhxpejandSNjslEAWpzxVQVzEYq3u42_Tf",
        ['admin-clearinv']      = "https://discord.com/api/webhooks/1438861989366464692/F9M4Jb9tQGojKDhfiT6QSl1E1JPyn-DRGjTdi6vZhJeSt40SXowWt1eS79bO-EznPVHB",
        ['admin-giveitemall']      = "https://discord.com/api/webhooks/1438919949195415613/jaq_urTyPeHUJgYpuWymXdC-R10K92IdagPdVq6MEzpSG6-qIwDjnz5zefMhz9RLHF33",
        ['admin-removeantytroll']  = "https://discord.com/api/webhooks/1438920068288479315/qoHjZCqH_QrZNJAJwxiyyrhjP_hSPGTZRlHayowkp4PtSmsKGExt6Aidz5IXDsPsMGwP",
        ['admin-clearinvoffline']  = "https://discord.com/api/webhooks/1438861989366464692/F9M4Jb9tQGojKDhfiT6QSl1E1JPyn-DRGjTdi6vZhJeSt40SXowWt1eS79bO-EznPVHB",
        ['admin-updatename']       = "https://discord.com/api/webhooks/1438920191164678164/kLTU5qcmTZFsTrkepP676FE6b_jjTIaHHbIssYvNHCGSrpzjm2OwsgJFaj6TesmIeZ9L",
        ['admin-launchboost']      = "",
        ['admin-screenshot']      = "https://discord.com/api/webhooks/1438920480559202366/JqA9Ws5O21ZV2LPnUtXXXay2Sk1ELlf4c5BQWhPCdRMdYAjulvV1QqIIvg7rYNiOSp5h",
        ['admin-deletecharacter'] = "https://discord.com/api/webhooks/1438920525802901524/nQA7v6kZKHFL5OLYSeFDH0_Nz3jFTpBTcS4XRxVjDe1Zn04i6JpdzHPOooEWxzkpKDIC",
        ['admin-slots']           = "https://discord.com/api/webhooks/1438920650721984582/jSd5D5JjWEvJISSX06H_MK4wk_fkS5zJfmciJPidEwowufiGp_tOiUuLlEN93eR5Bx3Z",
        ['admin-enablechar']      = "https://discord.com/api/webhooks/1438920697710772404/2DUS_Kp_k3jIP0txwW7XyHIRozegR9PfIhCAI6x9kBqT5JLj-z4sjDL13haaMHwPQkYN",
        ['admin-disablechar']     = "https://discord.com/api/webhooks/1438920697710772404/2DUS_Kp_k3jIP0txwW7XyHIRozegR9PfIhCAI6x9kBqT5JLj-z4sjDL13haaMHwPQkYN",
        ['admin-giveitem']        = "",
        ['admin-setjob']          = "https://discord.com/api/webhooks/1457852656843358375/s2qKVk_bHDRUyCuZCVReCkh3_NPQ_BGzbMLG1JJ_avKVV7baPZd-TBEjCs5CyzRr_qMN",
        ['admin-report']          = "https://discord.com/api/webhooks/1438909510394577069/K18FMgPwkoCN266PejQKeO-8OBzUGw9IbHhoiBMtIP-Viohv7OOXrd8XmROkrL5JB0Zw",
    
        ['bon-limitka']        = "https://discord.com/api/webhooks/1459761360727572697/z7e7NPY-WYlZQOiJiYhCYNg3yTVkvCcdXF6OVBBSav8CauhULfhoEjQicPiVye6ouQm3",
    },

    DefaultLink = "",
}

Config.ClearMapWebhook = ""

Config.InsertWebhook = ""

-- Konfiguracja automatycznego czyszczenia mapy (w minutach)
Config.AutoClearInterval = 30 -- Co ile minut automatycznie czyścić mapę

Config.OneBagInInventory = false

Config.BackpackStorage = {
    slots = 16,
    weight = 100000
}

Strings = {
    action_incomplete = 'Akcja zakończona niepowodzeniem!',
    one_backpack_only = 'Możesz mieć jedną torbe!',
    backpack_in_backpack = 'Nie możesz umieścić torby wewnątrz innej torby!',
}

Config.NPCstores = {
    ['Vangelico'] = {
        countNPC = math.random(2, 5),
        NPCSpawnCoords = vector4(-447.1218, -80.0086, 40.5408, 216.5503),
    },
    ['PacificStandard'] = {
        countNPC = math.random(5, 8),
        NPCSpawnCoords = vector4(235.2034, 216.8934, 106.2868, 116.4268),
    },
    ['HumaneLabs'] = {
        countNPC = math.random(4, 8),
        NPCSpawnCoords = vector4(3622.9294, 3739.6074, 28.6901, 325.1967),
    },
    ['Betta'] = {
        countNPC = math.random(2, 5),
        NPCSpawnCoords = vector4(-1231.5371, -334.7300, 37.3514, 26.5668),
    },
    ['Fleeca1'] = {
        countNPC = math.random(2, 4),
        NPCSpawnCoords = vector4(316.0302, -273.8705, 53.9158, 340.6483),
    },
    ['Fleeca2'] = {
        countNPC = math.random(2, 4),
        NPCSpawnCoords = vector4(151.2895, -1036.0035, 29.3392, 342.4827),
    },
    ['Fleeca3'] = {
        countNPC = math.random(2, 4),
        NPCSpawnCoords = vector4(-349.4394, -45.3057, 49.0368, 344.9551),
    },
    ['Fleeca4'] = {
        countNPC = math.random(2, 4),
        NPCSpawnCoords = vector4(-1215.5232, -325.3053, 37.6838, 30.1294),
    },
    ['Fleeca5'] = {
        countNPC = math.random(2, 4),
        NPCSpawnCoords = vector4(1175.0862, 2701.7964, 38.1733, 187.5074),
    },
    ['Fleeca6'] = {
        countNPC = math.random(2, 4),
        NPCSpawnCoords = vector4(-2968.1421, 482.9213, 15.4689, 86.4112),
    },
    ['OpuszczonaSiedzibaFIB'] = {
        countNPC = math.random(4, 7),
        NPCSpawnCoords = vector4(2484.9578, -384.0804, 93.7356, 276.2297),
    },
    ['ZbrojowniaLSPD'] = {
        countNPC = math.random(4, 7),
        NPCSpawnCoords = vector4(498.0824, -3133.7441, 6.0701, 96.2451),
    },
    ['BazaWojskowa'] = {
        countNPC = math.random(5, 8),
        NPCSpawnCoords = vector4(-2340.2964, 3263.0618, 32.8276, 242.3975),
    },
    ['Muzeum'] = {
        countNPC = math.random(3, 6),
        NPCSpawnCoords = vector4(-555.6107, -625.9815, 34.6767, 182.4716),
    },
    ['Mazebank'] = { 
        countNPC = math.random(1, 3),
        NPCSpawnCoords = vector4(-1312.2183, -829.2631, 17.1482, 167.6875),
    },
    ['Union'] = {
        countNPC = math.random(4, 6),
        NPCSpawnCoords = vector4(19.2500, -651.8125, 16.0881, 294.6368),
    },
    ['Artifact'] = {
        countNPC = math.random(5, 8),
        NPCSpawnCoords = vector4(-125.1536, -2657.8435, 6.0024, 272.2105),
    }
}