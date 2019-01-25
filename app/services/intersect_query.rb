# frozen_string_literal: true

# Creates a SQL query and the corresponding bind variables for
# the intersection (SQL INTERSECT) of several ActiveRecord::Relations
class IntersectQuery
  class << self
    def intersect(scopes)
      sql, binds = to_sql_and_binds build_intersect(scopes.map(&:arel))
      # Remove the unneeded parenthesis. See https://github.com/rails/rails/pull/34437
      # Strip outermost parens
      sql = sql.sub(/^\((.*)\)$/, '\1')

      # Strip parens from intersect clauses recursively.
      sql = sql.sub(/\((.*?)\) INTERSECT \((.*)\)/, '\1 INTERSECT \2') while /\) INTERSECT \(/.match?(sql)

      [sql, binds]
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
