package com.nuclear.hf.repository;

import com.nuclear.hf.entity.UncertaintyResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UncertaintyResultRepository extends JpaRepository<UncertaintyResult, Long> {

    List<UncertaintyResult> findByCaseTaskId(Long caseTaskId);
}
