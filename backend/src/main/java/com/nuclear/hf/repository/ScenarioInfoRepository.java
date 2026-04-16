package com.nuclear.hf.repository;

import com.nuclear.hf.entity.ScenarioInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScenarioInfoRepository extends JpaRepository<ScenarioInfo, Long> {

    List<ScenarioInfo> findByEventId(Long eventId);
}
