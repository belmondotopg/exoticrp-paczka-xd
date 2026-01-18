export let imagepath = 'images';

export function setImagePath(path: string) {
    if (path && path !== '') imagepath = path;
}

export const getImagePath = (img: string) => {
    if(img.includes('org') || img.includes('gang')){
        img = 'org'
    }
    const fp = `${imagepath}/${img}.png`;

    return fp;
};