package com.nuclear.hf.repository;

import com.nuclear.hf.entity.EventTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventTagRepository extends JpaRepository<EventTag, Long> {

    List<EventTag> findByEventId(Long eventId);
}
