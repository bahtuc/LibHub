package com.library.libhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.nio.charset.StandardCharsets;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;

import com.library.libhub.DTO.Response.BookImportResponse;
import com.library.libhub.entity.Books;
import com.library.libhub.repository.AuthorRepository;
import com.library.libhub.repository.BookRepository;
import com.library.libhub.repository.CategoryRepository;
import com.library.libhub.repository.PublisherRepository;

class BookImportServiceTest {

    private final BookRepository bookRepo = mock(BookRepository.class);
    private final AuthorRepository authorRepo = mock(AuthorRepository.class);
    private final CategoryRepository categoryRepo = mock(CategoryRepository.class);
    private final PublisherRepository publisherRepo = mock(PublisherRepository.class);
    private final BookImportService service = new BookImportService(
            bookRepo, authorRepo, categoryRepo, publisherRepo);

    @Test
    void csvImportSavesValidRowsAndReportsInvalidRows() {
        String csv = "title,isbn,publish_year,description,pages,category_id,author_id,publisher_id\n"
                + "Book A,ISBN-A,2025,\"Mô tả, có dấu phẩy\",200,1,1,1\n"
                + "Book B,ISBN-B,2025,Mô tả,-5,1,1,1\n";
        MockMultipartFile file = new MockMultipartFile(
                "file", "books.csv", "text/csv", csv.getBytes(StandardCharsets.UTF_8));

        when(bookRepo.findByIsbn("ISBN-A")).thenReturn(Optional.empty());
        when(bookRepo.findByIsbn("ISBN-B")).thenReturn(Optional.empty());
        when(categoryRepo.existsById(1L)).thenReturn(true);
        when(authorRepo.existsById(1L)).thenReturn(true);
        when(publisherRepo.existsById(1L)).thenReturn(true);

        BookImportResponse result = service.importBooks(file);

        assertEquals(2, result.totalRows());
        assertEquals(1, result.importedRows());
        assertEquals(1, result.skippedRows());
        assertEquals(3, result.errors().get(0).row());
        assertTrue(result.errors().get(0).message().contains("pages"));
        verify(bookRepo).saveAll(argThat(books -> {
            var iterator = books.iterator();
            Books saved = iterator.next();
            return !iterator.hasNext() && "Mô tả, có dấu phẩy".equals(saved.getDescription());
        }));
    }

    @Test
    void generatedXlsxTemplateCanBeImported() {
        when(bookRepo.findByIsbn("9786040000001")).thenReturn(Optional.empty());
        when(categoryRepo.existsById(1L)).thenReturn(true);
        when(authorRepo.existsById(1L)).thenReturn(true);
        when(publisherRepo.existsById(1L)).thenReturn(true);
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "template.xlsx",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                service.xlsxTemplate());

        BookImportResponse result = service.importBooks(file);

        assertEquals(1, result.totalRows());
        assertEquals(1, result.importedRows());
        assertEquals(0, result.skippedRows());
    }
}
