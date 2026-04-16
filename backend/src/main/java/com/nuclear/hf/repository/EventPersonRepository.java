package com.nuclear.hf.repository;

import com.nuclear.hf.entity.EventPerson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventPersonRepository extends JpaRepository<EventPerson, Long> {

    List<EventPerson> findByEventId(Long eventId);
}
