export type JobOffer = {
    id: string;
    title: string;
    category: {
        name: string;
        label: string;
    };
    description: string;
    image: string;
    address: string;
    salary: string;
    isAvailable: boolean;
}