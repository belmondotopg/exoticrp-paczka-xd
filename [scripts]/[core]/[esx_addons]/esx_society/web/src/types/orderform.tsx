export interface orderform_history {
    date: number,
    firstplayer_name: string,
    firstplayer_discordid: number,
    action: string,
    secondaction: string,
    secondplayer_name: string,
    secondplayer_discordid: number,
}[]

export default orderform_history