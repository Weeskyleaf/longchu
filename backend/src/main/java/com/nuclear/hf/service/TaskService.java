package com.nuclear.hf.service;

import com.nuclear.hf.entity.TaskUnit;
import com.nuclear.hf.repository.TaskUnitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskUnitRepository taskUnitRepository;

    public List<TaskUnit> findByEventId(Long eventId) {
        return taskUnitRepository.findByEventId(eventId);
    }

    public TaskUnit getById(Long id) {
        return taskUnitRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("任务单元不存在: " + id));
    }

    @Transactional
    public TaskUnit create(TaskUnit task) {
        return taskUnitRepository.save(task);
    }

    @Transactional
    public TaskUnit update(Long id, TaskUnit updated) {
        TaskUnit existing = getById(id);
        updated.setId(existing.getId());
        return taskUnitRepository.save(updated);
    }

    @Transactional
    public void delete(Long id) {
        if (!taskUnitRepository.existsById(id)) {
            throw new RuntimeException("任务单元不存在: " + id);
        }
        taskUnitRepository.deleteById(id);
    }
}
