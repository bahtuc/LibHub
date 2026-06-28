package com.library.libhub.service.impl;

import com.library.libhub.exception.ResourceNotFoundException;

import com.library.libhub.dao.PublisherDAO;
import com.library.libhub.entity.Publishers;
import com.library.libhub.service.IPublisherService;
import com.library.libhub.utils.ValidationUtil;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class PublisherServiceImpl implements IPublisherService {

    private final PublisherDAO publisherDAO;

    public PublisherServiceImpl(PublisherDAO publisherDAO) {
        this.publisherDAO = publisherDAO;
    }

    @Override
    public Publishers createPublisher(Publishers publisher) {
        validatePublisher(publisher);

        publisherDAO.findByPublisherName(publisher.getPublisherName().trim())
                .ifPresent(p -> {
                    throw new RuntimeException("Tên nhà xuất bản đã tồn tại");
                });

        publisher.setPublisherName(publisher.getPublisherName().trim());
        return publisherDAO.save(publisher);
    }

    @Override
    public Optional<Publishers> getPublisherById(long publisherId) {
        return publisherDAO.findById(publisherId);
    }

    @Override
    public List<Publishers> getAllPublishers() {
        return publisherDAO.findAll();
    }

    @Override
    public Publishers updatePublisher(long publisherId, Publishers publisher) {
        if (!publisherDAO.existsById(publisherId)) {
            throw new ResourceNotFoundException("Publisher not found with id: " + publisherId);
        }

        validatePublisher(publisher);

        publisherDAO.findByPublisherName(publisher.getPublisherName().trim())
                .filter(p -> !p.getPublisherId().equals(publisherId))
                .ifPresent(p -> {
                    throw new RuntimeException("Tên nhà xuất bản đã tồn tại");
                });

        publisher.setPublisherId(publisherId);
        publisher.setPublisherName(publisher.getPublisherName().trim());
        return publisherDAO.save(publisher);
    }

    @Override
    public void deletePublisher(long publisherId) {
        if (publisherDAO.existsById(publisherId)) {
            publisherDAO.deleteById(publisherId);
        } else {
            throw new ResourceNotFoundException("Publisher not found with id: " + publisherId);
        }
    }

    @Override
    public Optional<Publishers> findByName(String publisherName) {
        return publisherDAO.findByPublisherName(publisherName);
    }

    private void validatePublisher(Publishers publisher) {

        if (publisher == null) {
            throw new RuntimeException("Dữ liệu không hợp lệ");
        }

        if (!ValidationUtil.isNotBlank(publisher.getPublisherName())) {
            throw new RuntimeException("Tên nhà xuất bản không được để trống");
        }

        if (!ValidationUtil.maxLength(publisher.getPublisherName().trim(), 150)) {
            throw new RuntimeException("Tên nhà xuất bản không được vượt quá 150 ký tự");
        }

        if (publisher.getAddress() != null
                && !ValidationUtil.maxLength(publisher.getAddress(), 255)) {
            throw new RuntimeException("Địa chỉ không được vượt quá 255 ký tự");
        }

        // Số điện thoại không bắt buộc, nhưng nếu có thì phải hợp lệ
        if (ValidationUtil.isNotBlank(publisher.getPhone())
                && !ValidationUtil.isPhone(publisher.getPhone().trim())) {
            throw new RuntimeException("Số điện thoại không hợp lệ");
        }
    }
}
