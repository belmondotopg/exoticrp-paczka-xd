import { useMemo, useState } from "react";

function usePagination <T>(
    data: T[],
    itemsPerPage: number
) {
    const [page, setPage] = useState(0);

    const paginatedData = useMemo(() => {
        const startIndex = page * itemsPerPage;
        const endIndex = startIndex + itemsPerPage;

        return data.slice(startIndex, endIndex);
    }, [data, page, itemsPerPage]);

    const hasPreviousPage = useMemo(() => page > 0, [page]);
    const hasNextPage = useMemo(() => page < Math.ceil(data.length / itemsPerPage) - 1, [data.length, itemsPerPage, page]);

    return { page, setPage, paginatedData, hasPreviousPage, hasNextPage };
}

export { usePagination }