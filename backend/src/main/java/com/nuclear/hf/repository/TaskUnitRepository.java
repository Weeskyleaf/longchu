package com.nuclear.hf.repository;

import com.nuclear.hf.entity.TaskUnit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskUnitRepository extends JpaRepository<TaskUnit, Long> {

    List<TaskUnit> findByEventId(Long eventId);
}
