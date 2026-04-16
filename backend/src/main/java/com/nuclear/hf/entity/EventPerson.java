package com.nuclear.hf.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "event_person")
public class EventPerson {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "event_id", nullable = false)
    private Long eventId;

    @Column(name = "person_id", nullable = false)
    private Long personId;

    @Column(name = "involvement_type", nullable = false, length = 50)
    private String involvementType;

    @Column(name = "responsibility_desc", columnDefinition = "TEXT")
    private String responsibilityDesc;

    @Column(name = "behavior_note", columnDefinition = "TEXT")
    private String behaviorNote;
}
