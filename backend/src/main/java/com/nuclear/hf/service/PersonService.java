package com.nuclear.hf.service;

import com.nuclear.hf.entity.EventPerson;
import com.nuclear.hf.entity.PersonInfo;
import com.nuclear.hf.repository.EventPersonRepository;
import com.nuclear.hf.repository.PersonInfoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PersonService {

    private final PersonInfoRepository personInfoRepository;
    private final EventPersonRepository eventPersonRepository;

    public List<PersonInfo> listAll() {
        return personInfoRepository.findAll();
    }

    public PersonInfo getById(Long id) {
        return personInfoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("人员不存在: " + id));
    }

    @Transactional
    public PersonInfo create(PersonInfo person) {
        return personInfoRepository.save(person);
    }

    @Transactional
    public PersonInfo update(Long id, PersonInfo updated) {
        PersonInfo existing = getById(id);
        updated.setId(existing.getId());
        return personInfoRepository.save(updated);
    }

    @Transactional
    public void delete(Long id) {
        if (!personInfoRepository.existsById(id)) {
            throw new RuntimeException("人员不存在: " + id);
        }
        personInfoRepository.deleteById(id);
    }

    public List<EventPerson> findByEventId(Long eventId) {
        return eventPersonRepository.findByEventId(eventId);
    }

    @Transactional
    public EventPerson linkEvent(EventPerson eventPerson) {
        return eventPersonRepository.save(eventPerson);
    }

    @Transactional
    public void unlinkEvent(Long id) {
        if (!eventPersonRepository.existsById(id)) {
            throw new RuntimeException("事件人员关联不存在: " + id);
        }
        eventPersonRepository.deleteById(id);
    }
}
