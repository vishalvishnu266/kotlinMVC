package com.example.demo

import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.stereotype.Repository

@Repository
class DatabaseRepository(private val jdbcTemplate: JdbcTemplate) {
    fun getUsersWithOrders(): String? {
        val sql = "SELECT get_users_with_orders();"
        return jdbcTemplate.queryForObject(sql, String::class.java)
    }
}
