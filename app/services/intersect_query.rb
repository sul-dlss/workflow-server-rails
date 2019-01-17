# frozen_string_literal: true

# Creates a SQL query and the corresponding bind variables for
# the intersection (SQL INTERSECT) of several ActiveRecord::Relations
class IntersectQuery
  class << self
    def intersect(scopes)
      parts = []
      binds = []
      scopes.each do |scope|
        inner_sql, inner_binds = to_sql_and_binds(scope)
        parts << inner_sql
        binds += inner_binds
      end
      [parts.join(' INTERSECT '), binds]
    end

    private

    def to_sql_and_binds(scope)
      collector = Arel::Collectors::Composite.new(
        Arel::Collectors::SQLString.new,
        Arel::Collectors::Bind.new
      )
      WorkflowStep.connection.visitor.accept(scope.arel.ast, collector).value
    end
  end
end
