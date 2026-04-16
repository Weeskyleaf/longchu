package com.nuclear.hf.repository;

import com.nuclear.hf.entity.CasePsfValue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CasePsfValueRepository extends JpaRepository<CasePsfValue, Long> {

    List<CasePsfValue> findByCaseTaskId(Long caseTaskId);
}
