# LibHub DAO, Service, and API Implementation Guide

## Overview

This document provides a complete guide to the LibHub project's Data Access Object (DAO) layer, Service layer, REST API endpoints, and frontend axios utilities.

## Project Structure

### Backend Structure (LibHub)

```
src/main/java/com/library/libhub/
├── dao/                          # Data Access Objects (JPA Repositories)
│   ├── AuthorDAO.java
│   ├── BookDAO.java
│   ├── CategoryDAO.java
│   ├── PublisherDAO.java
│   ├── RoleDAO.java
│   ├── UserDAO.java
│   ├── BookCopyDAO.java
│   ├── BorrowTicketDAO.java
│   ├── BorrowDetailDAO.java
│   ├── ReturnDAO.java
│   ├── ReturnDetailDAO.java
│   └── FineDAO.java
├── service/
│   ├── I*Service.java                      # Service Interfaces (12 files)
│   └── impl/
│       └── *ServiceImpl.java                # Service Implementations (12 files)
├── controller/
│   ├── AuthorController.java
│   ├── BookController.java
│   ├── CategoryController.java
│   ├── PublisherController.java
│   ├── RoleController.java
│   ├── UserController.java
│   ├── BookCopyController.java
│   ├── BorrowTicketController.java
│   ├── BorrowDetailController.java
│   ├── ReturnController.java
│   ├── ReturnDetailController.java
│   └── FineController.java
├── entity/                       # JPA Entities (12 files)
└── utils/                        # Utility classes
```

### Frontend Structure (PMA-MyCoffee)

```
src/js/api/
├── libhubApi.js                  # Axios API client
├── apiHelper.js                  # Service helper with error handling
└── apiExamples.js                # Usage examples
```

## API Layers

### 1. Data Access Layer (DAO)

All DAOs extend `JpaRepository<Entity, Long>` providing:
- **Basic CRUD operations**: save(), findById(), findAll(), deleteById()
- **Custom query methods**: findBy*() methods
- **@Query annotations**: For complex queries
- **@Modifying**: For update/delete operations

**Example DAO:**
```java
@Repository
public interface AuthorDAO extends JpaRepository<Authors, Long> {
    // Inherited from JpaRepository: save, findById, findAll, delete, etc.
    // Custom methods can be added here
}
```

### 2. Service Layer

**Service Interfaces (IAuthorService, IBookService, etc.)**
- Define business logic contracts
- All service methods documented with clear purposes

**Service Implementations (AuthorServiceImpl, BookServiceImpl, etc.)**
- Implement @Service annotation
- Use @Transactional for transaction management
- Handle error cases with appropriate exceptions
- Delegate to DAOs for data access

**Example Service Implementation:**
```java
@Service
@Transactional
public class AuthorServiceImpl implements IAuthorService {
    
    private final AuthorDAO authorDAO;
    
    public AuthorServiceImpl(AuthorDAO authorDAO) {
        this.authorDAO = authorDAO;
    }
    
    @Override
    public Authors createAuthor(Authors author) {
        return authorDAO.save(author);
    }
    
    // Additional methods...
}
```

### 3. REST API Layer

All controllers implement RESTful endpoints with:
- **@RestController**: Handles REST requests
- **@CrossOrigin**: Enables CORS for frontend access
- **@RequestMapping**: Base path for endpoints
- **HTTP Methods**: GET, POST, PUT, DELETE
- **Exception Handling**: Proper HTTP status codes

**Available Endpoints:**

#### Author API (`/api/authors`)
- `GET /authors` - Get all authors
- `GET /authors/{id}` - Get author by ID
- `GET /authors/search?name=value` - Search by name
- `POST /authors` - Create author
- `PUT /authors/{id}` - Update author
- `DELETE /authors/{id}` - Delete author

#### Book API (`/api/books`)
- `GET /books` - Get all books
- `GET /books/{id}` - Get book by ID
- `GET /books/isbn/{isbn}` - Find by ISBN
- `GET /books/category/{categoryId}` - Find by category
- `GET /books/author/{authorId}` - Find by author
- `GET /books/search?keyword=value` - Search by title
- `POST /books` - Create book
- `PUT /books/{id}` - Update book
- `DELETE /books/{id}` - Delete book

#### User API (`/api/users`)
- `GET /users` - Get all users
- `GET /users/{id}` - Get user by ID
- `GET /users/username/{username}` - Find by username
- `GET /users/email/{email}` - Find by email
- `GET /users/check-username/{username}` - Check if username exists
- `POST /users` - Create user
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user
- `PUT /users/{id}/last-login` - Update last login time

**Similar endpoints available for:**
- Categories (`/api/categories`)
- Publishers (`/api/publishers`)
- Roles (`/api/roles`)
- Book Copies (`/api/book-copies`)
- Borrow Tickets (`/api/borrow-tickets`)
- Borrow Details (`/api/borrow-details`)
- Returns (`/api/returns`)
- Return Details (`/api/return-details`)
- Fines (`/api/fines`)

## Frontend Integration

### Installation

1. **Install axios:**
```bash
npm install axios
```

2. **Import API utilities:**
```javascript
import { authorAPI, bookAPI } from './api/libhubApi';
import { AuthorService, BookService } from './api/apiHelper';
```

### Usage Examples

#### Using Direct API Client (Low-level)
```javascript
import { authorAPI } from './api/libhubApi';

async function getAuthor(id) {
  try {
    const response = await authorAPI.getById(id);
    console.log(response.data);
  } catch (error) {
    console.error('Error:', error);
  }
}
```

#### Using Helper Services (High-level, Recommended)
```javascript
import { AuthorService } from './api/apiHelper';

async function loadAuthor(id) {
  const result = await AuthorService.fetchById(id);
  
  if (result.success) {
    console.log('Author:', result.data);
  } else {
    console.error('Error:', result.error);
  }
}
```

### Vue Component Example

```vue
<template>
  <div>
    <h1>Authors</h1>
    <button @click="loadAuthors">Load Authors</button>
    
    <div v-if="loading">Loading...</div>
    <div v-if="error" class="error">{{ error }}</div>
    
    <table v-if="authors.length">
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Biography</th>
      </tr>
      <tr v-for="author in authors" :key="author.authorId">
        <td>{{ author.authorId }}</td>
        <td>{{ author.authorName }}</td>
        <td>{{ author.biography }}</td>
      </tr>
    </table>
  </div>
</template>

<script>
import { AuthorService } from '@/api/apiHelper';

export default {
  data() {
    return {
      authors: [],
      loading: false,
      error: null,
    };
  },
  methods: {
    async loadAuthors() {
      this.loading = true;
      const result = await AuthorService.fetchAll();
      if (result.success) {
        this.authors = result.data;
        this.error = null;
      } else {
        this.error = result.error;
      }
      this.loading = false;
    },
  },
  mounted() {
    this.loadAuthors();
  },
};
</script>
```

## Common Workflows

### Borrow Book Workflow

```javascript
import { BorrowTicketService, BorrowDetailService, BookCopyService } from '@/api/apiHelper';

async function borrowBooks(userId, copyIds) {
  try {
    // 1. Create borrow ticket
    const ticketResult = await BorrowTicketService.create({
      userId,
      borrowDate: new Date().toISOString().split('T')[0],
      dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      status: 'ACTIVE',
    });

    if (!ticketResult.success) throw new Error(ticketResult.error);
    const ticketId = ticketResult.data.ticketId;

    // 2. Add books to borrow
    for (const copyId of copyIds) {
      await BorrowDetailService.create({
        ticketId,
        copyId,
        borrowStatus: 'ACTIVE',
      });

      // Update copy status to BORROWED
      await BookCopyService.updateStatus(copyId, 'BORROWED');
    }

    return { success: true, ticketId };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

### Return Book Workflow

```javascript
import { ReturnService, ReturnDetailService, BookCopyService } from '@/api/apiHelper';

async function returnBooks(ticketId, copyIds, receivedById) {
  try {
    // 1. Create return ticket
    const returnResult = await ReturnService.create({
      ticketId,
      returnDate: new Date().toISOString().split('T')[0],
      receivedBy: receivedById,
    });

    if (!returnResult.success) throw new Error(returnResult.error);
    const returnId = returnResult.data.returnId;

    // 2. Add return details
    for (const copyId of copyIds) {
      await ReturnDetailService.create({
        returnId,
        copyId,
        conditionBook: 'GOOD',
      });

      // Update copy status to AVAILABLE
      await BookCopyService.updateStatus(copyId, 'AVAILABLE');
    }

    return { success: true, returnId };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

## Error Handling

The API client includes built-in error handling:
- 401 errors automatically redirect to login
- All errors are caught and returned with descriptive messages
- Request/Response interceptors for token management

## Configuration

### Backend (application.properties)

```properties
# Server
server.port=8080

# Database
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=LibHub
spring.datasource.username=your_username
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# JPA
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
```

### Frontend (.env)

```
REACT_APP_API_URL=http://localhost:8080/api
```

## Security Considerations

1. **CORS Configuration**: Adjust `@CrossOrigin` origins for production
2. **Authentication**: Implement JWT or session-based auth
3. **Input Validation**: Validate all inputs on both frontend and backend
4. **SQL Injection**: Use JPA parameterized queries (already implemented)
5. **HTTPS**: Use HTTPS in production

## Testing

### Backend Testing Example

```java
@SpringBootTest
@AutoConfigureMockMvc
class AuthorControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void testGetAllAuthors() throws Exception {
        mockMvc.perform(get("/api/authors"))
            .andExpect(status().isOk());
    }
}
```

### Frontend Testing Example

```javascript
import { AuthorService } from '@/api/apiHelper';

describe('AuthorService', () => {
  it('should fetch all authors', async () => {
    const result = await AuthorService.fetchAll();
    expect(result.success).toBe(true);
    expect(Array.isArray(result.data)).toBe(true);
  });
});
```

## Performance Tips

1. **Pagination**: Add pagination for large datasets
2. **Caching**: Use Redis for frequently accessed data
3. **Lazy Loading**: Load related entities only when needed
4. **Database Indexing**: Index frequently searched columns
5. **API Response Time**: Monitor and optimize slow queries

## Future Enhancements

1. Add pagination and sorting to all endpoints
2. Implement advanced filtering options
3. Add authentication and authorization
4. Create GraphQL alternative to REST API
5. Implement caching layer
6. Add API documentation with Swagger/OpenAPI
7. Add rate limiting and request throttling
8. Implement webhook support for real-time updates

## Support

For issues or questions, refer to:
- Spring Boot Documentation: https://spring.io/projects/spring-boot
- JPA Documentation: https://spring.io/projects/spring-data-jpa
- Axios Documentation: https://axios-http.com/
- Vue.js Documentation: https://vuejs.org/

---

**Last Updated**: 2024
**Version**: 1.0.0
