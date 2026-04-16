package com.nuclear.hf.service;

import com.nuclear.hf.entity.EvidenceChain;
import com.nuclear.hf.repository.EvidenceChainRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EvidenceService {

    private final EvidenceChainRepository evidenceChainRepository;

    public List<EvidenceChain> findByEventId(Long eventId) {
        return evidenceChainRepository.findByEventId(eventId);
    }

    public EvidenceChain getById(Long id) {
        return evidenceChainRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("证据不存在: " + id));
    }

    @Transactional
    public EvidenceChain create(EvidenceChain evidence) {
        return evidenceChainRepository.save(evidence);
    }

    @Transactional
    public EvidenceChain update(Long id, EvidenceChain updated) {
        EvidenceChain existing = getById(id);
        updated.setId(existing.getId());
        return evidenceChainRepository.save(updated);
    }

    @Transactional
    public void delete(Long id) {
        if (!evidenceChainRepository.existsById(id)) {
            throw new RuntimeException("证据不存在: " + id);
        }
        evidenceChainRepository.deleteById(id);
    }
}
