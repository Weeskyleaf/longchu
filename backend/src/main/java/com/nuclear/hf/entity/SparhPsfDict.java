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
@Table(name = "sparh_psf_dict")
public class SparhPsfDict {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "psf_code", nullable = false, length = 32)
    private String psfCode;

    @Column(name = "psf_name", nullable = false, length = 100)
    private String psfName;

    @Column(name = "plant_mode", nullable = false, length = 20)
    private String plantMode;

    @Column(name = "task_type", nullable = false, length = 20)
    private String taskType;

    @Column(name = "level_code", nullable = false, length = 32)
    private String levelCode;

    @Column(name = "level_name", nullable = false, length = 100)
    private String levelName;

    @Column(name = "multiplier", nullable = false, precision = 12, scale = 6)
    private BigDecimal multiplier;

    @Column(name = "is_negative", nullable = false)
    private Integer isNegative = 0;

    @Column(name = "definition_text", columnDefinition = "TEXT")
    private String definitionText;

    @Column(name = "source_ref", length = 255)
    private String sourceRef;
}
