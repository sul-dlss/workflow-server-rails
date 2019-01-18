# frozen_string_literal: true

# Creates a SQL query and the corresponding bind variables for
# the intersection (SQL INTERSECT) of several ActiveRecord::Relations
class IntersectQuery
  class << self
    def intersect(scopes)
      sql, binds = to_sql_and_binds build_intersect(scopes.map(&:arel))
      # Remove the unneeded parenthesis. See https://github.com/rails/rails/pull/34437
      [sql.gsub(/[()]/, ''), binds]
    end

    private

    def build_intersect(scopes)
      if scopes.size == 1
        scopes[0]
      else
        Arel::Nodes::Intersect.new(scopes[0], build_intersect(scopes[1..-1]))
      end
    end

    def to_sql_and_binds(arel)
      collector = Arel::Collectors::Composite.new(
        Arel::Collectors::SQLString.new,
        Arel::Collectors::Bind.new
      )
      WorkflowStep.connection.visitor.accept(arel, collector).value
    end
  end
end
