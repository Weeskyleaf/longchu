package com.nuclear.hf.service;

import com.nuclear.hf.entity.EventTag;
import com.nuclear.hf.entity.TagDict;
import com.nuclear.hf.repository.EventTagRepository;
import com.nuclear.hf.repository.TagDictRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TagService {

    private final TagDictRepository tagDictRepository;
    private final EventTagRepository eventTagRepository;

    public List<TagDict> listDict() {
        return tagDictRepository.findAll();
    }

    public List<TagDict> listByType(String tagType) {
        return tagDictRepository.findByTagType(tagType);
    }

    public List<TagDict> listActive() {
        return tagDictRepository.findByIsActive(1);
    }

    @Transactional
    public TagDict createDict(TagDict tagDict) {
        return tagDictRepository.save(tagDict);
    }

    @Transactional
    public TagDict updateDict(Long id, TagDict updated) {
        TagDict existing = tagDictRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("标签字典不存在: " + id));
        updated.setId(existing.getId());
        return tagDictRepository.save(updated);
    }

    public List<EventTag> findTagsByEventId(Long eventId) {
        return eventTagRepository.findByEventId(eventId);
    }

    @Transactional
    public EventTag bindTag(EventTag eventTag) {
        return eventTagRepository.save(eventTag);
    }

    @Transactional
    public void unbindTag(Long id) {
        if (!eventTagRepository.existsById(id)) {
            throw new RuntimeException("事件标签关联不存在: " + id);
        }
        eventTagRepository.deleteById(id);
    }
}
