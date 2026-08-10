package com.library.libhub.DTO.Response;

import java.util.List;

public record BookImportResponse(
        int totalRows,
        int importedRows,
        int skippedRows,
        List<RowError> errors) {

    public record RowError(int row, String message) {
    }
}
