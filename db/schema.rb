# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "wt_block", primary_key: "block_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "gedcom_id"
    t.integer "user_id"
    t.string "xref", limit: 20
    t.string "location", limit: 4
    t.integer "block_order", null: false
    t.string "module_name", limit: 32, null: false
    t.index ["gedcom_id"], name: "fk1"
    t.index ["module_name"], name: "fk3"
    t.index ["user_id"], name: "fk2"
  end

  create_table "wt_block_setting", primary_key: ["block_id", "setting_name"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "block_id", null: false
    t.string "setting_name", limit: 32, null: false
    t.text "setting_value", null: false
  end

  create_table "wt_change", primary_key: "change_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.timestamp "change_time", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "status", limit: 8, default: "pending", null: false
    t.integer "gedcom_id", null: false
    t.string "xref", limit: 20, null: false
    t.text "old_gedcom", limit: 16777215, null: false
    t.text "new_gedcom", limit: 16777215, null: false
    t.integer "user_id", null: false
    t.index ["gedcom_id", "status", "xref"], name: "ix1"
    t.index ["user_id"], name: "fk1"
  end

  create_table "wt_dates", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "d_day", limit: 1, null: false
    t.string "d_month", limit: 5
    t.integer "d_mon", limit: 1, null: false
    t.integer "d_year", limit: 2, null: false
    t.integer "d_julianday1", limit: 3, null: false
    t.integer "d_julianday2", limit: 3, null: false
    t.string "d_fact", limit: 15, null: false
    t.string "d_gid", limit: 20, null: false
    t.integer "d_file", null: false
    t.string "d_type", limit: 13, null: false
    t.index ["d_day"], name: "ix1"
    t.index ["d_fact", "d_gid"], name: "ix10"
    t.index ["d_file"], name: "ix8"
    t.index ["d_gid"], name: "ix7"
    t.index ["d_julianday1"], name: "ix5"
    t.index ["d_julianday2"], name: "ix6"
    t.index ["d_mon"], name: "ix3"
    t.index ["d_month"], name: "ix2"
    t.index ["d_type"], name: "ix9"
    t.index ["d_year"], name: "ix4"
  end

  create_table "wt_default_resn", primary_key: "default_resn_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "gedcom_id", null: false
    t.string "xref", limit: 20
    t.string "tag_type", limit: 15
    t.string "resn", limit: 12, null: false
    t.string "comment"
    t.timestamp "updated", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["gedcom_id", "xref", "tag_type"], name: "ux1", unique: true
  end

  create_table "wt_families", primary_key: ["f_id", "f_file"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "f_id", limit: 20, null: false
    t.integer "f_file", null: false
    t.string "f_husb", limit: 20
    t.string "f_wife", limit: 20
    t.text "f_gedcom", limit: 16777215, null: false
    t.integer "f_numchil", null: false
    t.index ["f_file", "f_id"], name: "ux1", unique: true
    t.index ["f_husb"], name: "ix1"
    t.index ["f_wife"], name: "ix2"
  end

  create_table "wt_favorite", primary_key: "favorite_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "gedcom_id", null: false
    t.string "xref", limit: 20
    t.string "favorite_type", limit: 4, null: false
    t.string "url"
    t.string "title"
    t.string "note", limit: 1000
    t.index ["gedcom_id", "user_id"], name: "news_ix1"
    t.index ["user_id"], name: "favorite_fk1"
  end

  create_table "wt_gedcom", primary_key: "gedcom_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "gedcom_name", null: false
    t.integer "sort_order", default: 0, null: false
    t.index ["gedcom_name"], name: "ux1", unique: true
    t.index ["sort_order"], name: "ix1"
  end

  create_table "wt_gedcom_chunk", primary_key: "gedcom_chunk_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "gedcom_id", null: false
    t.binary "chunk_data", limit: 16777215, null: false
    t.boolean "imported", default: false, null: false
    t.index ["gedcom_id", "imported"], name: "ix1"
  end

  create_table "wt_gedcom_setting", primary_key: ["gedcom_id", "setting_name"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "gedcom_id", null: false
    t.string "setting_name", limit: 32, null: false
    t.string "setting_value", null: false
  end

  create_table "wt_hit_counter", primary_key: ["gedcom_id", "page_name", "page_parameter"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "gedcom_id", null: false
    t.string "page_name", limit: 32, null: false
    t.string "page_parameter", limit: 32, null: false
    t.integer "page_count", null: false
  end

  create_table "wt_individuals", primary_key: ["i_id", "i_file"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "i_id", limit: 20, null: false
    t.integer "i_file", null: false
    t.string "i_rin", limit: 20, null: false
    t.string "i_sex", limit: 1, null: false
    t.text "i_gedcom", limit: 16777215, null: false
    t.index ["i_file", "i_id"], name: "ux1", unique: true
  end

  create_table "wt_link", primary_key: ["l_from", "l_file", "l_type", "l_to"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "l_file", null: false
    t.string "l_from", limit: 20, null: false
    t.string "l_type", limit: 15, null: false
    t.string "l_to", limit: 20, null: false
    t.index ["l_to", "l_file", "l_type", "l_from"], name: "ux1", unique: true
  end

  create_table "wt_log", primary_key: "log_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.timestamp "log_time", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "log_type", limit: 6, null: false
    t.text "log_message", null: false
    t.string "ip_address", limit: 40, null: false
    t.integer "user_id"
    t.integer "gedcom_id"
    t.index ["gedcom_id"], name: "fk2"
    t.index ["ip_address"], name: "ix3"
    t.index ["log_time"], name: "ix1"
    t.index ["log_type"], name: "ix2"
    t.index ["user_id"], name: "fk1"
  end

  create_table "wt_media", primary_key: ["m_file", "m_id"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "m_id", limit: 20, null: false
    t.string "m_ext", limit: 6, null: false
    t.string "m_type", limit: 20, null: false
    t.string "m_titl", null: false
    t.string "m_filename", limit: 512, null: false
    t.integer "m_file", null: false
    t.text "m_gedcom", limit: 16777215, null: false
    t.index ["m_ext", "m_type"], name: "ix2"
    t.index ["m_id", "m_file"], name: "ix1"
    t.index ["m_titl"], name: "ix3"
  end

  create_table "wt_message", primary_key: "message_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "sender", limit: 64, null: false
    t.string "ip_address", limit: 40, null: false
    t.integer "user_id", null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.timestamp "created", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["user_id"], name: "fk1"
  end

  create_table "wt_module", primary_key: "module_name", id: :string, limit: 32, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "status", limit: 8, default: "enabled", null: false
    t.integer "tab_order"
    t.integer "menu_order"
    t.integer "sidebar_order"
  end

  create_table "wt_module_privacy", primary_key: ["module_name", "gedcom_id", "component"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "module_name", limit: 32, null: false
    t.integer "gedcom_id", null: false
    t.string "component", limit: 7, null: false
    t.integer "access_level", limit: 1, null: false
    t.index ["gedcom_id"], name: "fk2"
  end

  create_table "wt_module_setting", primary_key: ["module_name", "setting_name"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "module_name", limit: 32, null: false
    t.string "setting_name", limit: 32, null: false
    t.text "setting_value", limit: 16777215, null: false
  end

  create_table "wt_name", primary_key: ["n_id", "n_file", "n_num"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "n_file", null: false
    t.string "n_id", limit: 20, null: false
    t.integer "n_num", null: false
    t.string "n_type", limit: 15, null: false
    t.string "n_sort", null: false
    t.string "n_full", null: false
    t.string "n_surname"
    t.string "n_surn"
    t.string "n_givn"
    t.string "n_soundex_givn_std"
    t.string "n_soundex_surn_std"
    t.string "n_soundex_givn_dm"
    t.string "n_soundex_surn_dm"
    t.index ["n_full", "n_id", "n_file"], name: "ix1"
    t.index ["n_givn", "n_file", "n_type", "n_id"], name: "ix3"
    t.index ["n_surn", "n_file", "n_type", "n_id"], name: "ix2"
  end

  create_table "wt_news", primary_key: "news_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "gedcom_id"
    t.string "subject"
    t.text "body"
    t.timestamp "updated", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["gedcom_id", "updated"], name: "news_ix2"
    t.index ["user_id", "updated"], name: "news_ix1"
  end

  create_table "wt_next_id", primary_key: ["gedcom_id", "record_type"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "gedcom_id", null: false
    t.string "record_type", limit: 15, null: false
    t.decimal "next_id", precision: 20, null: false
  end

  create_table "wt_other", primary_key: ["o_id", "o_file"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "o_id", limit: 20, null: false
    t.integer "o_file", null: false
    t.string "o_type", limit: 15, null: false
    t.text "o_gedcom", limit: 16777215
    t.index ["o_file", "o_id"], name: "ux1", unique: true
  end

  create_table "wt_placelinks", primary_key: ["pl_p_id", "pl_gid", "pl_file"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "pl_p_id", null: false
    t.string "pl_gid", limit: 20, null: false
    t.integer "pl_file", null: false
    t.index ["pl_file"], name: "ix3"
    t.index ["pl_gid"], name: "ix2"
    t.index ["pl_p_id"], name: "ix1"
  end

  create_table "wt_placelocation", primary_key: "pl_id", id: :integer, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "pl_parent_id"
    t.integer "pl_level"
    t.string "pl_place"
    t.string "pl_long", limit: 30
    t.string "pl_lati", limit: 30
    t.integer "pl_zoom"
    t.string "pl_icon"
    t.string "pl_media", limit: 60
    t.float "sv_long", limit: 24, default: 0.0, null: false
    t.float "sv_lati", limit: 24, default: 0.0, null: false
    t.float "sv_bearing", limit: 24, default: 0.0, null: false
    t.float "sv_elevation", limit: 24, default: 0.0, null: false
    t.float "sv_zoom", limit: 24, default: 1.0, null: false
    t.index ["pl_lati"], name: "ix3"
    t.index ["pl_level"], name: "ix1"
    t.index ["pl_long"], name: "ix2"
    t.index ["pl_parent_id"], name: "ix5"
    t.index ["pl_place"], name: "ix4"
  end

  create_table "wt_places", primary_key: "p_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "p_place", limit: 150
    t.integer "p_parent_id"
    t.integer "p_file", null: false
    t.text "p_std_soundex"
    t.text "p_dm_soundex"
    t.index ["p_file", "p_place"], name: "ix1"
    t.index ["p_parent_id", "p_file", "p_place"], name: "ux1", unique: true
  end

  create_table "wt_session", primary_key: "session_id", id: :string, limit: 128, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.timestamp "session_time", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "user_id", null: false
    t.string "ip_address", limit: 32, null: false
    t.integer "session_height"
    t.string "session_type", limit: 20
    t.binary "session_data", limit: 16777215, null: false
    t.index ["session_time"], name: "ix1"
    t.index ["user_id", "ip_address"], name: "ix2"
  end

  create_table "wt_site_access_rule", primary_key: "site_access_rule_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "ip_address_start", default: 0, null: false, unsigned: true
    t.integer "ip_address_end", default: 4294967295, null: false, unsigned: true
    t.string "user_agent_pattern", null: false
    t.string "rule", limit: 7, default: "unknown", null: false
    t.string "comment", null: false
    t.timestamp "updated", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["ip_address_end", "ip_address_start", "user_agent_pattern", "rule"], name: "wt_site_access_rule_ix1", unique: true
    t.index ["rule"], name: "wt_site_access_rule_ix2"
  end

  create_table "wt_site_setting", primary_key: "setting_name", id: :string, limit: 32, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "setting_value", limit: 2000, null: false
  end

  create_table "wt_sources", primary_key: ["s_id", "s_file"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "s_id", limit: 20, null: false
    t.integer "s_file", null: false
    t.string "s_name", null: false
    t.text "s_gedcom", limit: 16777215, null: false
    t.index ["s_file", "s_id"], name: "ux1", unique: true
    t.index ["s_name"], name: "ix1"
  end

  create_table "wt_user", primary_key: "user_id", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "user_name", limit: 32, null: false
    t.string "real_name", limit: 64, null: false
    t.string "email", limit: 64, null: false
    t.string "password", limit: 128, null: false
    t.index ["email"], name: "ux2", unique: true
    t.index ["user_name"], name: "ux1", unique: true
  end

  create_table "wt_user_gedcom_setting", primary_key: ["user_id", "gedcom_id", "setting_name"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id", null: false
    t.integer "gedcom_id", null: false
    t.string "setting_name", limit: 32, null: false
    t.string "setting_value", null: false
    t.index ["gedcom_id"], name: "fk2"
  end

  create_table "wt_user_setting", primary_key: ["user_id", "setting_name"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id", null: false
    t.string "setting_name", limit: 32, null: false
    t.string "setting_value", null: false
  end

  add_foreign_key "wt_block", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_block_ibfk_1"
  add_foreign_key "wt_block", "wt_module", column: "module_name", primary_key: "module_name", name: "wt_block_ibfk_3"
  add_foreign_key "wt_block", "wt_user", column: "user_id", primary_key: "user_id", name: "wt_block_ibfk_2"
  add_foreign_key "wt_block_setting", "wt_block", column: "block_id", primary_key: "block_id", name: "wt_block_setting_ibfk_1"
  add_foreign_key "wt_change", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_change_ibfk_2"
  add_foreign_key "wt_change", "wt_user", column: "user_id", primary_key: "user_id", name: "wt_change_ibfk_1"
  add_foreign_key "wt_default_resn", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_default_resn_ibfk_1"
  add_foreign_key "wt_favorite", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_favorite_ibfk_2", on_delete: :cascade
  add_foreign_key "wt_favorite", "wt_user", column: "user_id", primary_key: "user_id", name: "wt_favorite_ibfk_1", on_delete: :cascade
  add_foreign_key "wt_gedcom_chunk", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_gedcom_chunk_ibfk_1"
  add_foreign_key "wt_gedcom_setting", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_gedcom_setting_ibfk_1"
  add_foreign_key "wt_hit_counter", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_hit_counter_ibfk_1"
  add_foreign_key "wt_log", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_log_ibfk_2"
  add_foreign_key "wt_log", "wt_user", column: "user_id", primary_key: "user_id", name: "wt_log_ibfk_1"
  add_foreign_key "wt_message", "wt_user", column: "user_id", primary_key: "user_id", name: "wt_message_ibfk_1"
  add_foreign_key "wt_module_privacy", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_module_privacy_ibfk_2"
  add_foreign_key "wt_module_privacy", "wt_module", column: "module_name", primary_key: "module_name", name: "wt_module_privacy_ibfk_1"
  add_foreign_key "wt_module_setting", "wt_module", column: "module_name", primary_key: "module_name", name: "wt_module_setting_ibfk_1"
  add_foreign_key "wt_news", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_news_ibfk_2", on_delete: :cascade
  add_foreign_key "wt_news", "wt_user", column: "user_id", primary_key: "user_id", name: "wt_news_ibfk_1", on_delete: :cascade
  add_foreign_key "wt_next_id", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_next_id_ibfk_1"
  add_foreign_key "wt_user_gedcom_setting", "wt_gedcom", column: "gedcom_id", primary_key: "gedcom_id", name: "wt_user_gedcom_setting_ibfk_2"
  add_foreign_key "wt_user_gedcom_setting", "wt_user", column: "user_id", primary_key: "user_id", name: "wt_user_gedcom_setting_ibfk_1"
  add_foreign_key "wt_user_setting", "wt_user", column: "user_id", primary_key: "user_id", name: "wt_user_setting_ibfk_1"
end
