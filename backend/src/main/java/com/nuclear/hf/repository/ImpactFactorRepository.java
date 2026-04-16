package com.nuclear.hf.repository;

import com.nuclear.hf.entity.ImpactFactor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ImpactFactorRepository extends JpaRepository<ImpactFactor, Long> {

    List<ImpactFactor> findByEventId(Long eventId);
}
