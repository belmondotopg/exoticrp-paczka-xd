export let imagepath = 'images';

export function setImagePath(path: string) {
    if(path && path !== '') imagepath = path;
}

export const getImagePath = (img: string) => {
    return `${imagepath}/${img}.png`
}