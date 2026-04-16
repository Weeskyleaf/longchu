package com.nuclear.hf.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "person_info")
public class PersonInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "person_code", nullable = false, unique = true, length = 64)
    private String personCode;

    @Column(name = "person_name", nullable = false, length = 100)
    private String personName;

    @Column(name = "department", length = 100)
    private String department;

    @Column(name = "role_name", length = 50)
    private String roleName;

    @Column(name = "experience_years", precision = 4, scale = 1)
    private BigDecimal experienceYears;

    @Column(name = "qualification_level", length = 50)
    private String qualificationLevel;

    @Column(name = "contact_info", length = 100)
    private String contactInfo;

    @Column(name = "note", length = 255)
    private String note;
}
