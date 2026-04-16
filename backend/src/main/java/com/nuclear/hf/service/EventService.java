package com.nuclear.hf.service;

import com.nuclear.hf.entity.*;
import com.nuclear.hf.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class EventService {

    private final EventMainRepository eventMainRepository;
    private final TaskUnitRepository taskUnitRepository;
    private final EventTagRepository eventTagRepository;
    private final ImpactFactorRepository impactFactorRepository;
    private final EvidenceChainRepository evidenceChainRepository;
    private final ScenarioInfoRepository scenarioInfoRepository;

    public Page<EventMain> listEvents(String eventType, String unitNo, String keyword, Pageable pageable) {
        return eventMainRepository.searchEvents(eventType, unitNo, keyword, pageable);
    }

    public EventMain getById(Long id) {
        return eventMainRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("事件不存在: " + id));
    }

    public Map<String, Object> getEventDetail(Long id) {
        EventMain event = getById(id);
        List<TaskUnit> tasks = taskUnitRepository.findByEventId(id);
        List<EventTag> tags = eventTagRepository.findByEventId(id);
        List<ImpactFactor> factors = impactFactorRepository.findByEventId(id);
        List<EvidenceChain> evidences = evidenceChainRepository.findByEventId(id);
        List<ScenarioInfo> scenarios = scenarioInfoRepository.findByEventId(id);

        Map<String, Object> detail = new HashMap<>();
        detail.put("event", event);
        detail.put("tasks", tasks);
        detail.put("tags", tags);
        detail.put("factors", factors);
        detail.put("evidences", evidences);
        detail.put("scenarios", scenarios);
        return detail;
    }

    @Transactional
    public EventMain createEvent(EventMain event) {
        return eventMainRepository.save(event);
    }

    @Transactional
    public EventMain updateEvent(Long id, EventMain updated) {
        EventMain existing = getById(id);
        updated.setId(existing.getId());
        updated.setCreatedAt(existing.getCreatedAt());
        return eventMainRepository.save(updated);
    }

    @Transactional
    public void deleteEvent(Long id) {
        if (!eventMainRepository.existsById(id)) {
            throw new RuntimeException("事件不存在: " + id);
        }
        eventMainRepository.deleteById(id);
    }

    public Map<String, Object> getStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", eventMainRepository.count());
        stats.put("byType", toNameValueList(eventMainRepository.countByEventTypeGrouped()));
        stats.put("byUnit", toNameValueList(eventMainRepository.countByUnitNoGrouped()));
        stats.put("byMonth", toNameValueList(eventMainRepository.countByMonthGrouped()));
        stats.put("byConsequence", toNameValueList(eventMainRepository.countByConsequenceLevelGrouped()));
        return stats;
    }

    private List<Map<String, Object>> toNameValueList(List<Object[]> rows) {
        return rows.stream()
                .map(r -> Map.<String, Object>of("name", r[0] != null ? r[0].toString() : "未知", "value", ((Number) r[1]).longValue()))
                .collect(java.util.stream.Collectors.toList());
    }
}
