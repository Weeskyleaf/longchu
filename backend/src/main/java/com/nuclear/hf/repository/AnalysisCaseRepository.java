package com.nuclear.hf.repository;

import com.nuclear.hf.entity.AnalysisCase;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AnalysisCaseRepository extends JpaRepository<AnalysisCase, Long> {

    List<AnalysisCase> findByMethodCode(String methodCode);
}
