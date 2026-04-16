package com.nuclear.hf.repository;

import com.nuclear.hf.entity.EvidenceChain;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EvidenceChainRepository extends JpaRepository<EvidenceChain, Long> {

    List<EvidenceChain> findByEventId(Long eventId);
}
