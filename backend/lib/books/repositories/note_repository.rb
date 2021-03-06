class NoteRepository < Hanami::Repository
  # rubocop:disable Metrics/AbcSize
  def count(element_ids)
    counts = relations[:notes]
      .where(element_id: element_ids)
      .select { [element_id, int.count(id).as(:count)] }
      .group(:element_id)
      .order(nil)
      .as(NoteCount)
      .to_a

    missing = element_ids.select { |id| counts.none? { |c| c.element_id == id } }
    counts += missing.map { |m| NoteCount.new(element_id: m, count: 0) }
    counts.map { |element_id:, count:| [element_id, count] }.to_h
  end
  # rubocop:enable Metrics/AbcSize

  def close(id)
    update(id, state: "closed")
  end

  def open(id)
    update(id, state: "open")
  end
end
