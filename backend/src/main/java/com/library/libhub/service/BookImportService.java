package com.library.libhub.service;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.time.Year;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.library.libhub.DTO.Response.BookImportResponse;
import com.library.libhub.DTO.Response.BookImportResponse.RowError;
import com.library.libhub.entity.Books;
import com.library.libhub.repository.AuthorRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.repository.CategoryRepository;
import com.library.libhub.repository.PublisherRepository;

@Service
public class BookImportService {

    private static final int MAX_ROWS = 5_000;
    private static final long MAX_FILE_SIZE = 10L * 1024 * 1024;
    private static final List<String> HEADERS = List.of(
            "title", "isbn", "publish_year", "description", "cover_image", "language", "pages",
            "category_id", "author_id", "publisher_id", "is_hidden", "is_featured");

    private final BookRepository bookRepo;
    private final AuthorRepository authorRepo;
    private final CategoryRepository categoryRepo;
    private final PublisherRepository publisherRepo;

    public BookImportService(
            BookRepository bookRepo,
            AuthorRepository authorRepo,
            CategoryRepository categoryRepo,
            PublisherRepository publisherRepo) {
        this.bookRepo = bookRepo;
        this.authorRepo = authorRepo;
        this.categoryRepo = categoryRepo;
        this.publisherRepo = publisherRepo;
    }

    @Transactional
    public BookImportResponse importBooks(MultipartFile file) {
        validateFile(file);
        List<Map<String, String>> rows = readRows(file);
        if (rows.size() > MAX_ROWS) {
            throw new IllegalArgumentException("File chỉ được chứa tối đa " + MAX_ROWS + " dòng dữ liệu");
        }

        List<Books> validBooks = new ArrayList<>();
        List<RowError> errors = new ArrayList<>();
        Set<String> isbnsInFile = new HashSet<>();

        for (int index = 0; index < rows.size(); index++) {
            int displayRow = index + 2;
            try {
                Books book = toBook(rows.get(index), isbnsInFile);
                validBooks.add(book);
            } catch (IllegalArgumentException exception) {
                errors.add(new RowError(displayRow, exception.getMessage()));
            }
        }

        bookRepo.saveAll(validBooks);
        return new BookImportResponse(rows.size(), validBooks.size(), errors.size(), List.copyOf(errors));
    }

    public byte[] csvTemplate() {
        String example = "Sách mẫu,9786040000001,2026,Mô tả,https://example.com/cover.jpg,Tiếng Việt,200,1,1,1,false,false";
        return ("\uFEFF" + String.join(",", HEADERS) + "\n" + example + "\n")
                .getBytes(StandardCharsets.UTF_8);
    }

    public byte[] xlsxTemplate() {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Books");
            Row header = sheet.createRow(0);
            for (int column = 0; column < HEADERS.size(); column++) {
                header.createCell(column).setCellValue(HEADERS.get(column));
                sheet.setColumnWidth(column, column == 3 ? 12_000 : 4_500);
            }
            Row example = sheet.createRow(1);
            List<Object> values = List.of("Sách mẫu", "9786040000001", 2026, "Mô tả", "", "Tiếng Việt",
                    200, 1, 1, 1, false, false);
            for (int column = 0; column < values.size(); column++) {
                Object value = values.get(column);
                Cell cell = example.createCell(column);
                if (value instanceof Number number) cell.setCellValue(number.doubleValue());
                else if (value instanceof Boolean bool) cell.setCellValue(bool);
                else cell.setCellValue(String.valueOf(value));
            }
            workbook.write(output);
            return output.toByteArray();
        } catch (IOException exception) {
            throw new IllegalStateException("Không tạo được file Excel mẫu", exception);
        }
    }

    private Books toBook(Map<String, String> row, Set<String> isbnsInFile) {
        String title = text(row, "title");
        if (title == null) throw new IllegalArgumentException("Thiếu title");

        String isbn = text(row, "isbn");
        if (isbn != null) {
            String normalizedIsbn = isbn.replaceAll("[-\\s]", "").toLowerCase(Locale.ROOT);
            if (!isbnsInFile.add(normalizedIsbn)) throw new IllegalArgumentException("ISBN bị trùng trong file: " + isbn);
            if (bookRepo.findByIsbn(isbn).isPresent()) throw new IllegalArgumentException("ISBN đã tồn tại: " + isbn);
        }

        Integer publishYear = integer(row, "publish_year");
        if (publishYear != null && (publishYear < 0 || publishYear > Year.now().getValue() + 1)) {
            throw new IllegalArgumentException("publish_year không hợp lệ");
        }
        Integer pages = integer(row, "pages");
        if (pages != null && pages <= 0) throw new IllegalArgumentException("pages phải lớn hơn 0");

        Long categoryId = longValue(row, "category_id");
        Long authorId = longValue(row, "author_id");
        Long publisherId = longValue(row, "publisher_id");
        if (categoryId != null && !categoryRepo.existsById(categoryId)) {
            throw new IllegalArgumentException("Không tìm thấy category_id=" + categoryId);
        }
        if (authorId != null && !authorRepo.existsById(authorId)) {
            throw new IllegalArgumentException("Không tìm thấy author_id=" + authorId);
        }
        if (publisherId != null && !publisherRepo.existsById(publisherId)) {
            throw new IllegalArgumentException("Không tìm thấy publisher_id=" + publisherId);
        }

        Books book = new Books();
        book.setTitle(title);
        book.setIsbn(isbn);
        book.setPublishYear(publishYear);
        book.setDescription(text(row, "description"));
        book.setCoverImage(text(row, "cover_image"));
        book.setLanguage(text(row, "language"));
        book.setPages(pages);
        book.setCategoryId(categoryId);
        book.setAuthorId(authorId);
        book.setPublisherId(publisherId);
        book.setHidden(bool(row, "is_hidden", false));
        book.setFeatured(bool(row, "is_featured", false));
        book.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        return book;
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) throw new IllegalArgumentException("Vui lòng chọn file CSV hoặc Excel");
        if (file.getSize() > MAX_FILE_SIZE) throw new IllegalArgumentException("File không được lớn hơn 10 MB");
        String name = file.getOriginalFilename() == null ? "" : file.getOriginalFilename().toLowerCase(Locale.ROOT);
        if (!name.endsWith(".csv") && !name.endsWith(".xlsx") && !name.endsWith(".xls")) {
            throw new IllegalArgumentException("Chỉ hỗ trợ file .csv, .xls hoặc .xlsx");
        }
    }

    private List<Map<String, String>> readRows(MultipartFile file) {
        String name = file.getOriginalFilename() == null ? "" : file.getOriginalFilename().toLowerCase(Locale.ROOT);
        try {
            return name.endsWith(".xlsx") || name.endsWith(".xls")
                    ? readExcel(file.getBytes())
                    : readCsv(file.getBytes());
        } catch (IOException exception) {
            throw new IllegalArgumentException("Không đọc được file: " + exception.getMessage(), exception);
        }
    }

    private List<Map<String, String>> readExcel(byte[] bytes) throws IOException {
        try (Workbook workbook = WorkbookFactory.create(new ByteArrayInputStream(bytes))) {
            Sheet sheet = workbook.getNumberOfSheets() == 0 ? null : workbook.getSheetAt(0);
            if (sheet == null || sheet.getPhysicalNumberOfRows() == 0) throw new IllegalArgumentException("File Excel không có dữ liệu");
            DataFormatter formatter = new DataFormatter(Locale.ROOT);
            Row headerRow = sheet.getRow(sheet.getFirstRowNum());
            List<String> headers = new ArrayList<>();
            for (int column = 0; column < headerRow.getLastCellNum(); column++) {
                headers.add(normalizeHeader(formatter.formatCellValue(headerRow.getCell(column))));
            }
            requireHeaders(headers);
            List<Map<String, String>> rows = new ArrayList<>();
            for (int rowIndex = headerRow.getRowNum() + 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
                Row row = sheet.getRow(rowIndex);
                if (row == null) continue;
                Map<String, String> values = new LinkedHashMap<>();
                boolean hasValue = false;
                for (int column = 0; column < headers.size(); column++) {
                    String value = formatter.formatCellValue(row.getCell(column)).trim();
                    values.put(headers.get(column), value);
                    hasValue |= !value.isEmpty();
                }
                if (hasValue) rows.add(values);
            }
            return rows;
        }
    }

    private List<Map<String, String>> readCsv(byte[] bytes) throws IOException {
        String content = new String(bytes, StandardCharsets.UTF_8);
        if (content.startsWith("\uFEFF")) content = content.substring(1);
        List<List<String>> records = parseCsv(content);
        if (records.isEmpty()) throw new IllegalArgumentException("File CSV không có dữ liệu");
        List<String> headers = records.get(0).stream().map(this::normalizeHeader).toList();
        requireHeaders(headers);
        List<Map<String, String>> rows = new ArrayList<>();
        for (int index = 1; index < records.size(); index++) {
            List<String> record = records.get(index);
            if (record.stream().allMatch(String::isBlank)) continue;
            Map<String, String> values = new LinkedHashMap<>();
            for (int column = 0; column < headers.size(); column++) {
                values.put(headers.get(column), column < record.size() ? record.get(column).trim() : "");
            }
            rows.add(values);
        }
        return rows;
    }

    private List<List<String>> parseCsv(String content) throws IOException {
        List<List<String>> records = new ArrayList<>();
        List<String> currentRecord = new ArrayList<>();
        StringBuilder field = new StringBuilder();
        boolean quoted = false;
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(
                new ByteArrayInputStream(content.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8))) {
            int value;
            while ((value = reader.read()) != -1) {
                char character = (char) value;
                if (quoted) {
                    if (character == '"') {
                        reader.mark(1);
                        int next = reader.read();
                        if (next == '"') field.append('"');
                        else {
                            quoted = false;
                            if (next != -1) reader.reset();
                        }
                    } else field.append(character);
                } else if (character == '"' && field.length() == 0) quoted = true;
                else if (character == ',') {
                    currentRecord.add(field.toString());
                    field.setLength(0);
                } else if (character == '\n') {
                    currentRecord.add(trimCr(field.toString()));
                    records.add(currentRecord);
                    currentRecord = new ArrayList<>();
                    field.setLength(0);
                } else field.append(character);
            }
        }
        if (quoted) throw new IllegalArgumentException("CSV có dấu ngoặc kép chưa đóng");
        if (field.length() > 0 || !currentRecord.isEmpty()) {
            currentRecord.add(trimCr(field.toString()));
            records.add(currentRecord);
        }
        return records;
    }

    private void requireHeaders(List<String> headers) {
        if (!headers.contains("title")) throw new IllegalArgumentException("File phải có cột title");
        Set<String> allowed = new HashSet<>(HEADERS);
        List<String> unknown = headers.stream().filter(header -> !allowed.contains(header)).toList();
        if (!unknown.isEmpty()) throw new IllegalArgumentException("Cột không được hỗ trợ: " + String.join(", ", unknown));
    }

    private String normalizeHeader(String value) {
        return value == null ? "" : value.trim().toLowerCase(Locale.ROOT).replace(' ', '_');
    }

    private String text(Map<String, String> row, String key) {
        String value = row.get(key);
        return value == null || value.isBlank() ? null : value.trim();
    }

    private Integer integer(Map<String, String> row, String key) {
        String value = text(row, key);
        if (value == null) return null;
        try {
            return (int) Double.parseDouble(value);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(key + " phải là số");
        }
    }

    private Long longValue(Map<String, String> row, String key) {
        String value = text(row, key);
        if (value == null) return null;
        try {
            return (long) Double.parseDouble(value);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(key + " phải là số");
        }
    }

    private boolean bool(Map<String, String> row, String key, boolean defaultValue) {
        String value = text(row, key);
        if (value == null) return defaultValue;
        return switch (value.toLowerCase(Locale.ROOT)) {
            case "true", "1", "yes", "có", "co" -> true;
            case "false", "0", "no", "không", "khong" -> false;
            default -> throw new IllegalArgumentException(key + " phải là true hoặc false");
        };
    }

    private String trimCr(String value) {
        return value.endsWith("\r") ? value.substring(0, value.length() - 1) : value;
    }
}
