package com.nuclear.hf.service;

import com.nuclear.hf.entity.ImpactFactor;
import com.nuclear.hf.repository.ImpactFactorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FactorService {

    private final ImpactFactorRepository impactFactorRepository;

    public List<ImpactFactor> findByEventId(Long eventId) {
        return impactFactorRepository.findByEventId(eventId);
    }

    public ImpactFactor getById(Long id) {
        return impactFactorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("影响因素不存在: " + id));
    }

    @Transactional
    public ImpactFactor create(ImpactFactor factor) {
        return impactFactorRepository.save(factor);
    }

    @Transactional
    public ImpactFactor update(Long id, ImpactFactor updated) {
        ImpactFactor existing = getById(id);
        updated.setId(existing.getId());
        return impactFactorRepository.save(updated);
    }

    @Transactional
    public void delete(Long id) {
        if (!impactFactorRepository.existsById(id)) {
            throw new RuntimeException("影响因素不存在: " + id);
        }
        impactFactorRepository.deleteById(id);
    }
}
