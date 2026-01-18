export type RadioMember = {
    name: string;
    tag?: string;
    isTalking?: boolean;
    isDead?: boolean;
}

export type RadioData = {
    channel: number | string;
    channelNumber?: number;
    maxMembers?: number;
    members: RadioMember[];
    radioType?: string;
}