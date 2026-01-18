export const DocumentMugshot = ({ url }: { url: string }) => {
    return (
        <img
            src={url}
            alt=""
            className="size-[58px] rounded-lg shadow-sm object-cover object-center"
        />
    )
}