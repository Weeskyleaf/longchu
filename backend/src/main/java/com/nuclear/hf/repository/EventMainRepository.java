package com.nuclear.hf.repository;

import com.nuclear.hf.entity.EventMain;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventMainRepository extends JpaRepository<EventMain, Long> {

    List<EventMain> findByEventType(String eventType);

    List<EventMain> findByUnitNo(String unitNo);

    @Query("SELECT e FROM EventMain e WHERE " +
           "(:eventType IS NULL OR e.eventType = :eventType) AND " +
           "(:unitNo IS NULL OR e.unitNo = :unitNo) AND " +
           "(:keyword IS NULL OR e.eventTitle LIKE %:keyword% OR e.eventCode LIKE %:keyword% OR e.rawText LIKE %:keyword%)")
    Page<EventMain> searchEvents(@Param("eventType") String eventType,
                                 @Param("unitNo") String unitNo,
                                 @Param("keyword") String keyword,
                                 Pageable pageable);

    long countByEventType(String eventType);

    long countByUnitNo(String unitNo);

    long countByConsequenceLevel(String consequenceLevel);

    @Query("SELECT e.eventType, COUNT(e) FROM EventMain e GROUP BY e.eventType")
    List<Object[]> countByEventTypeGrouped();

    @Query("SELECT e.unitNo, COUNT(e) FROM EventMain e GROUP BY e.unitNo")
    List<Object[]> countByUnitNoGrouped();

    @Query("SELECT YEAR(e.occurTime), MONTH(e.occurTime), COUNT(e) FROM EventMain e GROUP BY YEAR(e.occurTime), MONTH(e.occurTime) ORDER BY YEAR(e.occurTime), MONTH(e.occurTime)")
    List<Object[]> countByMonthGrouped();

    @Query("SELECT e.consequenceLevel, COUNT(e) FROM EventMain e GROUP BY e.consequenceLevel")
    List<Object[]> countByConsequenceLevelGrouped();
}
