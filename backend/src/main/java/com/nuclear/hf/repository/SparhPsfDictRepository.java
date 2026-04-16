package com.nuclear.hf.repository;

import com.nuclear.hf.entity.SparhPsfDict;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SparhPsfDictRepository extends JpaRepository<SparhPsfDict, Long> {

    List<SparhPsfDict> findByPlantModeAndTaskType(String plantMode, String taskType);
}
