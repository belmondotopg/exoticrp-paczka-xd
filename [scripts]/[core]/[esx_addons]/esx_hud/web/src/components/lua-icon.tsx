import { useMemo } from "react";
import * as Lucide from "lucide-react";
import * as FontAwesome from "react-icons/fa6";
import * as Bootstrap from "react-icons/bs";
import * as MaterialDesign from "react-icons/md";

type IconLibrary = "lucide" | "fa" | "bs" | "md";
type LibraryType = typeof Lucide | typeof FontAwesome | typeof Bootstrap | typeof MaterialDesign;

const librariesNames: IconLibrary[] = ["lucide"]

const libraries: Record<IconLibrary, LibraryType> = {
    lucide: Lucide,
    fa: FontAwesome,
    bs: Bootstrap,
    md: MaterialDesign
}

interface Props {
    name: string;
    className?: string;
    style?: React.CSSProperties;
}

const formatIconName = (name: string, defaultValue = {
    library: "lucide" as IconLibrary,
    name: "Info"
}) => {
    const [library, ...splited]  = name.toLowerCase().split("-");
    
    if (!library || !librariesNames.includes(library as IconLibrary)) {
        return defaultValue;
    }

    const iconName = splited.map((str) => str.charAt(0).toUpperCase() + str.slice(1));

    if (library !== "lucide") {
        iconName.unshift(library.charAt(0).toUpperCase() + library.slice(1));
    }

    return {
        library: library as IconLibrary,
        name: iconName.join("")
    }
}

export const LuaIcon = ({
    name = "lucide-info",
    className,
    style
}: Props) => {
    const Icon = useMemo<Lucide.LucideIcon>(() => {
        const {
            library,
            name: iconName
        } = formatIconName(name);

        try {
            const libraryObj = libraries[library];

            // @ts-ignore
            const icon = libraryObj[iconName] ?? null;

            if (!icon) {
                throw new Error("Icon not found");
            } else {
                return icon
            }
        } catch {
            return Lucide.Info;
        }
    }, [name]);

    return (
        <Icon
            className={className}
            style={style}
        />
    )
}