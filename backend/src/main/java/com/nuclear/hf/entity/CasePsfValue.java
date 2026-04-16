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
@Table(name = "case_psf_value")
public class CasePsfValue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "case_task_id", nullable = false)
    private Long caseTaskId;

    @Column(name = "psf_code", nullable = false, length = 32)
    private String psfCode;

    @Column(name = "psf_name", nullable = false, length = 100)
    private String psfName;

    @Column(name = "level_code", nullable = false, length = 32)
    private String levelCode;

    @Column(name = "level_name", nullable = false, length = 100)
    private String levelName;

    @Column(name = "multiplier", nullable = false, precision = 12, scale = 6)
    private BigDecimal multiplier;

    @Column(name = "is_negative", nullable = false)
    private Integer isNegative = 0;

    @Column(name = "basis_text", columnDefinition = "TEXT")
    private String basisText;
}
