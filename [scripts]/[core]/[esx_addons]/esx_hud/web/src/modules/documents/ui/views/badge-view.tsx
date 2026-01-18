import { useVisible } from "@yankes/fivem-react/hooks";

import { DocumentBox } from "../components/document-box"
import { DocumentMugshot } from "../components/document-mugshot";
import { DocumentSsn } from "../components/document-ssn";
import { DocumentStat } from "../components/document-stat";
import { useBadge } from "../../api/use-badge";
import { DocumentFooter } from "../components/document-footer";

export const BadgeView = () => {
    const { visible } = useVisible("badge", false);
    const data = useBadge();

    return data && (
        <DocumentBox visible={visible} className="flex flex-col gap-y-6">
            <div className="flex items-start gap-x-4">
                <div className="flex flex-col">
                    <DocumentMugshot url={data.mugshot} />
                    <DocumentSsn ssn={data.ssn} className="w-full truncate mt-2.5" />
                </div>
                <div className="flex-1 flex flex-col gap-y-3.5">
                    <span className="font-semibold text-sm line-clamp-2 wrap-anywhere">
                        {data.firstName}{" "}{data.lastName}
                    </span>
                    <div className="w-full grid grid-cols-2 gap-x-2.5">
                        <DocumentStat label="Odznaka">
                            {data.badge}
                        </DocumentStat>
                        <DocumentStat label="Stopień">
                            {data.grade}
                        </DocumentStat>
                    </div>
                    <DocumentStat label="Frakcja">
                        {data.fraction}
                    </DocumentStat>
                </div>
            </div>
            <DocumentFooter />
        </DocumentBox>
    )
}