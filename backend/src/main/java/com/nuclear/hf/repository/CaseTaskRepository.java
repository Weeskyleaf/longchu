package com.nuclear.hf.repository;

import com.nuclear.hf.entity.CaseTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CaseTaskRepository extends JpaRepository<CaseTask, Long> {

    List<CaseTask> findByCaseId(Long caseId);
}
