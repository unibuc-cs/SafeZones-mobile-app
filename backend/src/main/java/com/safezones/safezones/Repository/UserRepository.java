package com.safezones.safezones.Repository;

import com.safezones.safezones.Model.User;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;


public interface UserRepository extends CrudRepository<User, String> {
    @Modifying
    @Query(value = "DELETE FROM user_contacts WHERE user_id = :userId AND contact_id = :contactId", nativeQuery = true)
    void deleteContact(@Param("userId") String userId, @Param("contactId") String contactId);
}   