import { format } from "date-fns";
import { useVisible } from "@yankes/fivem-react/hooks";

import { cn } from "@/lib/utils";

import { DocumentBox } from "../components/document-box"
import { DocumentFooter } from "../components/document-footer";
import { DocumentMugshot } from "../components/document-mugshot";
import { useDocumentId } from "../../api/use-document-id";
import { DocumentSsn } from "../components/document-ssn";
import { DocumentStat } from "../components/document-stat";

export const DocumentIdView = () => {
    const { visible } = useVisible("document-id", false);
    const data = useDocumentId();

    return data && (
        <DocumentBox visible={visible} className="flex flex-col gap-y-6">
            <div className="flex items-center gap-x-4">
                <div className="flex flex-col max-w-[70px] items-center">
                    <DocumentMugshot url={data.mugshot} />
                    <span className="text-sm font-semibold text-center line-clamp-2 wrap-anywhere mt-4">
                        {data.firstName} {data.lastName}
                    </span>
                    <DocumentSsn ssn={data.ssn} className="w-[50px] truncate mt-1" />
                </div>
                <div className="flex-1 grid grid-cols-2 gap-2.5">
                    <DocumentStat label="Data urodzenia">
                        {data.birthDate && !isNaN(data.birthDate) ? format(new Date(data.birthDate * 1000), "dd.MM.yyyy") : "N/A"}
                    </DocumentStat>
                    <DocumentStat label="Płeć">
                        {data.gender === "m" ? "M" : "K"}
                    </DocumentStat>
                    <DocumentStat label="Kraj Pochodzenia">
                        {data.nationality}
                    </DocumentStat>
                    <DocumentStat label="Licencja na Broń">
                        {data.gunLicense ? "Posiada" : <span className="text-[hsla(var(--primary-hsl)_/_0.5)]">Brak</span>}
                    </DocumentStat>
                    <DocumentStat label="Wzrost">
                        {data.height} cm
                    </DocumentStat>
                    <DocumentStat label="Prawo Jazdy">
                        <span className={cn("uppercase", !data.drivingLicense.a && "text-[hsla(var(--primary-hsl)_/_0.5)]")}>a</span>{" "}
                        <span className={cn("uppercase", !data.drivingLicense.b && "text-[hsla(var(--primary-hsl)_/_0.5)]")}>b</span>{" "}
                        <span className={cn("uppercase", !data.drivingLicense.c && "text-[hsla(var(--primary-hsl)_/_0.5)]")}>c</span>
                    </DocumentStat>
                </div>
            </div>
            <DocumentFooter />
        </DocumentBox>
    )
}