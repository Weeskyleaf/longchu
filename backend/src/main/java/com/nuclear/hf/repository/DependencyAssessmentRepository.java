package com.nuclear.hf.repository;

import com.nuclear.hf.entity.DependencyAssessment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DependencyAssessmentRepository extends JpaRepository<DependencyAssessment, Long> {

    List<DependencyAssessment> findByCaseId(Long caseId);
}
