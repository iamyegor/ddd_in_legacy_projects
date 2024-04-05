﻿using ACL.ConnectionStrings;
using ACL.Synchronizers.Delivery.Models;
using Dapper;
using Newtonsoft.Json;
using Npgsql;

namespace ACL.Synchronizers.Delivery.Repositories;

public class BubbleOutboxRepository
{
    private readonly NpgsqlConnection? _connection;
    private readonly NpgsqlTransaction? _transaction;

    public BubbleOutboxRepository(NpgsqlConnection connection, NpgsqlTransaction transaction)
    {
        _connection = connection;
        _transaction = transaction;
    }

    public BubbleOutboxRepository() { }

    public void Save(List<DeliveryInLegacy> deliveriesToSave, string type)
    {
        ArgumentNullException.ThrowIfNull(_connection);
        ArgumentNullException.ThrowIfNull(_transaction);
        
        var deliveriesAsJson = deliveriesToSave.Select(delivery => new
        {
            Content = JsonConvert.SerializeObject(delivery)
        });

        string query =
            @$"
            insert into outbox (content, type)
            values (@Content::jsonb, '{type}')";

        _connection.Execute(query, deliveriesAsJson, transaction: _transaction);
    }

    public (List<int>, List<T>) Get<T>(string type)
    {
        using var connection = new NpgsqlConnection(BubbleConnectionString.Value);

        string query =
            @"
            select id as Id, content as Content
            from outbox
            where type = @type";

        List<OutboxRow> outboxRows = connection.Query<OutboxRow>(query, new { type }).ToList();

        List<T> objectsToReturn = [];
        foreach (var json in outboxRows.Select(r => r.Content))
        {
            T? deserializedObject = JsonConvert.DeserializeObject<T>(json);
            if (deserializedObject == null)
            {
                throw new Exception("Couldn't deserialize outbox entry");
            }

            objectsToReturn.Add(deserializedObject);
        }

        List<int> ids = outboxRows.Select(r => r.Id).ToList();

        return (ids, objectsToReturn);
    }

    public void Remove(List<int> ids)
    {
        using var connection = new NpgsqlConnection(BubbleConnectionString.Value);

        string query =
            @"
            delete from outbox
            where id = @id";

        connection.Execute(query, ids.Select(id => new { id }));
    }
}
