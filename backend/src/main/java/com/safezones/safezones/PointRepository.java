package com.safezones.safezones;

import com.safezones.safezones.points.Point;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface PointRepository extends CrudRepository<Point, Integer> {
    List<Point> findByUserId(String userId);
}
