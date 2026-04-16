package com.nuclear.hf.repository;

import com.nuclear.hf.entity.EvidenceIndex;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EvidenceIndexRepository extends JpaRepository<EvidenceIndex, Long> {

    List<EvidenceIndex> findByCaseId(Long caseId);
}
