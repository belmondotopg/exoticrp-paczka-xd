import { useVisible } from "@yankes/fivem-react/hooks";

import { DocumentBox } from "../components/document-box"
import { DocumentMugshot } from "../components/document-mugshot";
import { DocumentSsn } from "../components/document-ssn";
import { DocumentStat } from "../components/document-stat";
import { useBusinessCard } from "../../api/use-business-card";

export const BusinessCardView = () => {
    const { visible } = useVisible("business-card", false);
    const data = useBusinessCard();

    return data && (
        <DocumentBox visible={visible} className="flex items-start gap-x-4">
            <div className="flex flex-col">
                <DocumentMugshot url={data.mugshot} />
                <DocumentSsn ssn={data.ssn} className="w-full truncate mt-2.5" />
            </div>
            <div className="flex-1 flex flex-col gap-y-3.5">
                <span className="font-semibold text-sm line-clamp-2 wrap-anywhere">
                    {data.firstName}{" "}{data.lastName}
                </span>
                <DocumentStat label="Numer tel.">
                    {data.phoneNumber}
                </DocumentStat>
                <DocumentStat label="Zawód">
                    {data.job}
                </DocumentStat>
            </div>
        </DocumentBox>
    )
}